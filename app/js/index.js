$(document).ready(function () {
  document.getElementById('candle-base').title = 'Click to relight the candle';

  Shiny.addCustomMessageHandler('updateCandle', function (data) {
    document.getElementById('candle').style.height = data.candle_height + 'px';
    document.getElementById('flame').style.top = data.flame_position + 'px';
    document.getElementById('wick').style.height = data.wick_height + 'px';

    document.getElementById('candle-info').innerHTML =
      'Days until renewal: ' + data.days_remaining;
  });
});
