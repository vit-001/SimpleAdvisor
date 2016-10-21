//+------------------------------------------------------------------+
//|                                                    Analytics.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Candlestick.mqh"
#include "Logger.mqh"
#include "Grafer.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Analytics
  {
private:
   Logger           *logg;
   Grafer           *graf;

public:
     Analytics(Logger &logger,Grafer &grafer)
     {
      logg=GetPointer(logger);
      graf=GetPointer(grafer);
     };
     
     ~Analytics(){};
     
     void on_init()
     {
     }
     
     void on_de_init()
     {
     }
     
  };
  
   
  

