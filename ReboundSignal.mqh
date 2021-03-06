//+------------------------------------------------------------------+
//|                                                ReboundSignal.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays\ArrayObj.mqh>


#define REBOUND_ARRAY_LENGHT 5

#include "Candlestick.mqh"
#include "CandlestickHandler.mqh"
#include "CandlestickM1Solver.mqh"
#include "MovingAverage.mqh"
#include "Analytics.mqh"
//#include "grafer.mqh"
#include "Trader.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ReboundSignal:public CandlestickHandler
  {
private:

   Analytics        *an;
   MovingAverage    *ma;
   Trader           *trader;
   //Grafer           *graph;

   datetime          next_time;

   Candlestick      *current_candle;
   int               base_period;
   int               start_minute;
   int               ma_period;
   double            signal_level;

   CArrayObj        *candles;

public:
                     ReboundSignal(CandlestickM1Solver &cs,Analytics &analytics,Trader &tr,
                                                     int BasePeriod=10,int StartMinute=3,int MAperiod=14,double SignalLevel=5.0);
                    ~ReboundSignal();

   int               min_couunt;
   int               max_couunt;
   int               min_signal_count;
   int               max_signal_count;

   void              on_candle(datetime time,Candlestick &candle);

private:

   bool              test_min_of_4();
   bool              test_max_of_4();
   datetime          calc_next_time(datetime time);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ReboundSignal::ReboundSignal(CandlestickM1Solver &cs,Analytics &analytics, Trader &tr,
                             int BasePeriod=10,int StartMinute=3,int MAperiod=14,double SignalLevel=5.0)
  {
   an=GetPointer(analytics);
   trader=GetPointer(tr);
   //graph=GetPointer(grapher);

   base_period=BasePeriod;
   start_minute=StartMinute;
   ma_period=MAperiod;
   signal_level=SignalLevel;

   ma=new MovingAverage(cs,base_period*(ma_period+1));
   cs.add_on_candle_handler(GetPointer(this));

   candles=new CArrayObj();
//candles.Reserve(16);
   current_candle=NULL;

   min_couunt=max_couunt=min_signal_count=max_signal_count=0;

   //graph.add_viewport();
   //graph.add_candle("M1",0);
   //graph.add_line("MA",0);

   //Print(TimeCurrent());

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ReboundSignal::~ReboundSignal()
  {
   delete ma;
   delete candles;
   if(current_candle!=NULL) delete current_candle;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReboundSignal::on_candle(datetime time,Candlestick &candle)
  {

   if(current_candle==NULL) current_candle=new Candlestick();
   current_candle.add(candle);

   if((time/M1_PERIOD)%base_period==start_minute)
     {
      //Print(time,(time/60)%base_period);
      //graph.plot("M1",time,current_candle);
      //graph.plot("MA",time,ma.median.lma(ma_period*base_period));
      
      candles.Insert(current_candle,0);
      if(candles.Total()>REBOUND_ARRAY_LENGHT)
        {
         candles.Delete(REBOUND_ARRAY_LENGHT);
        }

      if(test_min_of_4())
        {
         min_couunt++;
         double spread=candle.last_spread();
         if(spread<0.00001) spread=0.00001;

         double delta=(ma.median.lma(ma_period*base_period)-current_candle.close())/spread;
         
         

         if(delta>signal_level)
           {
            // Выполнено условие торгового сигнала
            if(trader.buy()) min_signal_count++;
           }
        }

      if(test_max_of_4())
        {
         max_couunt++;
         double spread=candle.last_spread();
         if(spread<0.00001) spread=0.00001;

         double delta=(ma.median.lma(ma_period*base_period)-current_candle.close())/spread;

         if(delta<-signal_level)
           {
            // Выполнено условие торгового сигнала
            //if(trader.sell()) max_signal_count++;
           }

        }

      current_candle=NULL;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ReboundSignal::test_min_of_4(void)
  {
   if(candles.Total()<4) return false;

   double L0=dynamic_cast<Candlestick*>(candles.At(0)).low();
   double L1=dynamic_cast<Candlestick*>(candles.At(1)).low();
   double L2=dynamic_cast<Candlestick*>(candles.At(2)).low();
   double L3=dynamic_cast<Candlestick*>(candles.At(3)).low();

   if(L1<=L0 && L1<=L2 && L1<=L3)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ReboundSignal::test_max_of_4(void)
  {
   if(candles.Total()<4) return false;

   double H0=dynamic_cast<Candlestick*>(candles.At(0)).high();
   double H1=dynamic_cast<Candlestick*>(candles.At(1)).high();
   double H2=dynamic_cast<Candlestick*>(candles.At(2)).high();
   double H3=dynamic_cast<Candlestick*>(candles.At(3)).high();

   if(H1>=H0 && H1>=H2 && H1>=H3)
      return true;
   else
      return false;
  }
  
datetime ReboundSignal::calc_next_time(datetime time)
{



return time;
}

//+------------------------------------------------------------------+
