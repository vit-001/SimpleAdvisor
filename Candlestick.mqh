//+------------------------------------------------------------------+
//|                                                  Candlestick.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>
//+------------------------------------------------------------------+
//|    класс свечки                                                  |
//+------------------------------------------------------------------+
class Candlestick:public CObject
  {
private:

   double            _open;
   double            _close;
   double            _high;
   double            _low;

   bool              _valid;

   double            _spread;
   double            _last_spread;

public:
                     Candlestick(void) {  _valid=false; _spread=_last_spread=0.0; };
                     Candlestick(double open_bid,double open_ask) { _open=_close=_high=_low=open_bid; _spread=_last_spread=open_ask-open_bid; };

   void re_init(){_valid=false;};
   void re_init(double bid,double ask){ re_init(); add(bid,ask);}

   void              add(double bid,double ask);
   void              add(Candlestick &candle);

   void              print(){  PrintFormat("CS:(%.5f,%.5f,%.5f,%.5f)",_open,_high,_low,_close);  };

   double open() {return _open;}
   double close() {return _close;}
   double high() {return _high;}
   double low() {return _low;}
   
   double spread() {return _spread;}
   double last_spread() {return _last_spread;}

  };
//+------------------------------------------------------------------+
//|     ввод текущего тика в свечку                                  |
//+------------------------------------------------------------------+
void Candlestick::add(double bid,double ask)
  {
   if(_valid)
     {
      _close=bid;
      if(bid<_low) _low=bid;
      if(bid>_high) _high=bid;

     }
   else
     {
      _open=_close=_high=_low=bid;
      _valid=true;
     }
     
     _last_spread=ask-bid;
     _spread=MathMax(_spread,_last_spread);
     
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Candlestick::add(Candlestick &candle)
  {
   if(_valid)
     {
      _close=candle.close();
      _low=MathMin(_low,candle.low());
      _high=MathMax(_high,candle.high());
     }
   else
     {
      _open=candle.open();
      _close=candle.close();
      _high=candle.high();
      _low=candle.low();
      _valid=true;
     }
     
     _last_spread=candle.last_spread();
      _spread=MathMax(_spread,candle.spread());     
  }

//+------------------------------------------------------------------+
