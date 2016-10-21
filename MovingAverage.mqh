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
   Logger           *logger;
public:

                     MovingAverage(CandlestickM1Solver &cs_solver,int dimension,Logger &current_logger);
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
   //logger.sp();
   //logger.out_rate(median.lma(14));
   //logger.sp();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage::MovingAverage(CandlestickM1Solver &cs,int dimension,Logger &current_logger)
  {
   logger=GetPointer(current_logger);

   median=new MovingAverageSimpleArray(dimension);
   cs.add_on_candle_handler(GetPointer(this));

   current_logger.out_string_nl("MovingAverage init");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage::~MovingAverage()
  {
   delete median;
  }
//+------------------------------------------------------------------+
