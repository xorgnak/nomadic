
## queue
# manage job queues.
# queue name => [ job, job, job ]
# queue name, new_job => [ job, job, job, new_job ]
# queue => [ main_queue_job ]
# queue << new_job => [ main_queue_job, new_main_queue_job ]
def queue *q
  if q[0]
    if q[1]
      Redis::List.new("queue:#{q[0]}") << q[1]
    else
      Redis::List.new("queue:#{q[0]}")
    end
  else
    Redis::List.new("queue:main")
  end
end

def gen_id *i
  if i[0]
    n = i[0].to_i
  else
    n = 6
  end
  @a = []
  until @a.join('') != '' && !Redis::HashKey.new("JOBS").has_key?(@a.join(''))
    n.times {@a << rand(9)}
  end
  return @a.join('')
end

class Job
  include Redis::Objects
  def initialize h={}
    if h[:id]
      @id = h[:id]
    else
      @id = gen_id
      self.state.value = h.delete(:state) || "NEW"
      self.from.value = h.delete(:from)
      if h[:to]
        self.to.value = h.delete(:to)
      elsif h[:queue]
        self.to.value = h.delete(:queue)
        queue(self.to.value, @id)
      else
        queue << @id
      end
      h.each_pair {|k,v| self.attrs[k] = v }
    end
  end
  def id
    @id
  end
  value :state
  value :from
  value :to
  hash_key :attrs
end

## job from: 'user', [ to: 'user', queue: 'queue', ( order: 'order', price: 1, location: 'locatioon' ) ]
# create or access a job.
#  required:
#    from: the user creating the job.
#  optional:
#    to: the specific user the job is assigned to.
#    queue: the queue the job is assigned to.
#  attributes:
#    order: the contents of the job.
#    price: the amount of credit paid for the job.
#    location: the location for the job to be delivered.
def job h
  Job.new h
end
