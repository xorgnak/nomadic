var canvas;
var context;
var W;
var H;

var R = 6;
var points = [];
var randomPoints = [];
var staticPoints = [];

var B = 5;
var N = 10;

var bb = 3;
var BB = 7;
var NN = 4;


var bbb = 2;
var BBB = 4;
var NNN = 3;

window.onresize = setDimensions;

window.onload = function() {

  canvas = document.getElementById( 'canvas' );
  context = canvas.getContext( '2d' );
  
  for( var i = 0; i < N; i ++ ) {
    points[i] = [];
    randomPoints[i] = [];
    staticPoints[i] = [];
  }
  
  setDimensions();
  
}

function setDimensions() {
  W = window.innerWidth;
  H = window.innerHeight;
  canvas.width = W;
  canvas.height = H;
  update();
}

function bigPaths( B, N ) {
  for( var i = 0; i < B; i ++ ) {
    var w1 = i * ( W / B ) - randomVal( 0, 40 );
    var w2 = ( i + 1 ) * ( W / B ) + randomVal( 0, 40 );

    getPoints( w1, w2, 0, H, N );
    drawCircuit( N, '#8F945C' );
  }
}

function mediumPaths( b, B, N ) {
  for( var i = 0; i < B; i ++ ) {
    for( var j = 0; j < b; j ++ ) {
      var w1 = i * ( W / B ) - randomVal( 0, 40 );
      var w2 = ( i + 1 ) * ( W / B ) + randomVal( 0, 40 );
      var h1 = j * ( H / b ) + randomVal( 0, 20 );
      var h2 = ( j + 1 ) * ( H / b) - randomVal( 0, 20 );

      getPoints( w1, w2, h1, h2, N );
      drawCircuit( N, '#525C44' );
    }
  }
}

function smallPaths( b, B, N ) {
  for( var i = 0; i < B; i ++ ) {
    for( var j = 0; j < b; j ++ ) {
      var w1 = i * ( W / B ) + randomVal( 0, 100 );
      var w2 = ( i + 1 ) * ( W / B ) - randomVal( 0, 100 );
      var h1 = j * ( H / b ) + randomVal( 0, 40 );
      var h2 = ( j + 1 ) * ( H / b) - randomVal( 0, 40 );

      getPoints( w1, w2, h1, h2, N );
      drawCircuit( N, '#283227' );
    }
  }
}


function getPoints( W1, W2, H1, H2, N ) {
  
  var width = W2 - W1;
  var height = H2 - H1;
  
  for( var j = 0; j < 2; j ++ ) {
    for( var i = 0; i < N; i ++ ) {
      
      var w1 = j * ( width / 2 ) + W1;
      var w2 = ( j + 1 ) * ( width / 2 ) + W1;
      var h1 = i * ( height / N ) + H1;
      var h2 = ( i + 1 ) * ( height / N ) + H1;
      
      points[i][j] = randomPoz( w1, w2, h1, h2 );
      
      randomPoints[i][j] = randomPoz( w1, w2, h1, h2 );
      
      var x = randomPoints[i][j].x - points[i][j].x;
      var y = randomPoints[i][j].y - points[i][j].y;
      var angle = Math.atan2( y, x );
      var X = points[i][j].x - 20 * Math.cos( angle );
      var Y = points[i][j].y - 20 * Math.sin( angle );
      
      staticPoints[i][j] = new Point( X, Y );
    }
  }
}

function Point( x, y ) {
  this.x = x;
  this.y = y;
  this.r = R;
  this.color = '#ff0000';
  
  this.draw = function() {
    context.beginPath();
    context.globalAlpha = 0.7;
    context.arc( this.x, this.y, this.r, 0, 2 * Math.PI );
    context.fillStyle = this.color;
    context.fill();
    context.globalAlpha = 1;
  };
}

function randomPoz( w1, w2, h1, h2 ) {
  var x = randomVal( w1, w2 );
  var y = randomVal( h1, h2 );
  var p = new Point( x, y );
  return p;
}

function drawCircuit( N, color ) {
  context.beginPath();
  context.moveTo( points[0][0].x, points[0][0].y );
  
  for( var i = 0; i < N ; i ++ ) {
      if( i == N - 1 ) {
        context.bezierCurveTo( staticPoints[i][0].x, staticPoints[i][0].y, randomPoints[i][1].x, randomPoints[i][1].y, points[i][1].x, points[i][1].y);
      } else {
        context.bezierCurveTo( staticPoints[i][0].x, staticPoints[i][0].y, randomPoints[i + 1][0].x, randomPoints[i + 1][0].y, points[i + 1][0].x, points[i + 1][0].y);
      }
  }

 for( var i = N - 1; i >= 0 ; i -- ) {
      if( i == 0 ) {
        context.bezierCurveTo( staticPoints[i][1].x, staticPoints[i][1].y, randomPoints[i][0].x, randomPoints[i][0].y, points[i][0].x, points[i][0].y );
      } else {
        context.bezierCurveTo( staticPoints[i][1].x, staticPoints[i][1].y, randomPoints[i - 1][1].x, randomPoints[i - 1][1].y, points[i - 1][1].x, points[i - 1][1].y);
      }
  }
  
  context.fillStyle= color;
  context.lineWidth = 2;
  context.fill();
}

function randomVal( min, max ) {
  return Math.random() * ( max - min ) + min;
}

function update() {
  context.clearRect( 0, 0, W, H );
  bigPaths( B, N );
  mediumPaths( bb, BB, NN );
  smallPaths( bbb, BBB, NNN );
}
