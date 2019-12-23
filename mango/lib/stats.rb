require 'sentimental'
class CoOccour
  def initialize k
    @k = k
    @sentiment = Sentimental.new
    @sentiment.load_defaults
    @words = Redis::SortedSet.new("#{k}:cooccur:words")
    @feeling = Redis::SortedSet.new("#{k}:cooccur:feeling")
    @occour = Redis::SortedSet.new("#{k}:cooccour:feeling")
  end
  def tag str
    s = @sentiment.sentiment str
    w = str.gsub('.', '').gsub(',','').gsub('?','').gsub('!','').split(' ')
    w.each { |e|
      if s == :positive
        @feeling.incr(e)
      elsif s == :negative
        @feeling.decr(e)
      end
      w.each { |ee|
               if ee != e;
                 add(e, ee);
                 if s == :positive
                   @occour.incr(e + ":" + ee)
                   @occour.incr(ee + ":" + e)
                 elsif s == :negative
                   @occour.decr(e + ":" + ee)
                   @occour.decr(ee + ":" + e)
                 end
               end
             }
    }
  end
  def words
    @words.members(with_scores: true).to_h.sort_by {|k,v| -v }.to_h
  end
  def feeling
    @feeling.members(with_scores: true).to_h.sort_by {|k,v|-v }.to_h
  end
  def occour
    @occour.members(with_scores: true).to_h.sort_by {|k,v| -v}.to_h
  end
  def [] k
    Redis::SortedSet.new("#{@k}:cooccour:#{k}").members(with_scores: true).to_h.sort_by {|k,v| -v }.to_h
  end
  def add w, k
    @words.incr(k)
    Redis::SortedSet.new("#{@k}:cooccour:#{w}").incr(k)
  end
end
## stats
# access stats about sentiment and cooocourance of language.
# s = stats(:index) => CoOccour.new(:index)
# s.words => An index of word usage frequency.
# s.occour => An index of co-occouring words.
# s.feeling => An index of word feeling.
# s.tag(string) => add string to indexes. 
def stats k
  CoOccour.new(k) 
end
