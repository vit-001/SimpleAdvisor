//+------------------------------------------------------------------+
//|                                           CandlestickHandler.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include  "Candlestick.mqh"

//+------------------------------------------------------------------+
//|    Интерфейс для вызова функции при выходе свечки                |
//+------------------------------------------------------------------+
class CandlestickHandler
  {
public:
   virtual void      on_candle(datetime time,Candlestick &candle)=NULL;
  };