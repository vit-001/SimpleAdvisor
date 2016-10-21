//+------------------------------------------------------------------+
//|                                                MovingAverage.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "MovingAverageSimpleArray.mqh"
#include "CandlestickM1solver.mqh"
#include "CandlestickHandler.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MovingAverage:public CandlestickHandler
  {
private:
public:

                     MovingAverage(CandlestickM1Solver &cs_solver,int dimension);
                    ~MovingAverage();

   MovingAverageSimpleArray *median;
   void              on_candle(datetime time,Candlestick &candle);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAverage::on_candle(datetime time,Candlestick &candle)
  {
   median.add((candle.high()+candle.low())/2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage::MovingAverage(CandlestickM1Solver &cs,int dimension)
  {
   median=new MovingAverageSimpleArray(dimension);
   cs.add_on_candle_handler(GetPointer(this));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage::~MovingAverage()
  {
   delete median;
  }
//+------------------------------------------------------------------+
