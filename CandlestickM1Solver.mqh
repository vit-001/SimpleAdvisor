//+------------------------------------------------------------------+
//|                                          CandlestickM1Solver.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include  "Candlestick.mqh"
#include "CandlestickHandler.mqh"
//#include "Logger.mqh"

#define M1_PERIOD (60)
#define MAX_CS_CALLBACKS (10)
//+------------------------------------------------------------------+
//|    Класс формирует минутные свечки по событию on_tick            |
//|    и оповещает об этом зарегистрированные handler'ы              |
//+------------------------------------------------------------------+
class CandlestickM1Solver
  {
private:
   Candlestick       candle;
   Candlestick       accumulator;
   datetime          next_time;
   CandlestickHandler *handlers[MAX_CS_CALLBACKS];
   //Logger           *logger;

   datetime          calc_next_time(datetime time);

public:
                     CandlestickM1Solver();

   void              on_tick(datetime time,double bid,double ask);
   bool              add_on_candle_handler(CandlestickHandler *handler);
  };
//+------------------------------------------------------------------+
//|     Конструктор инициализирует время свечки и массив handler'ов  |
//+------------------------------------------------------------------+
CandlestickM1Solver::CandlestickM1Solver()
  {
   //logger=GetPointer(current_logger);

//Print("CandlestickSolver init");

   next_time = calc_next_time(TimeCurrent());

   for(int i=0; i<MAX_CS_CALLBACKS; i++)
      handlers[i]=NULL;

//Print(next_time);

   //logger.out_string_nl("CandlestickSolver init");

  }
//+------------------------------------------------------------------+
//|     Метод должен вызываться на каждом тике                       |
//+------------------------------------------------------------------+
void CandlestickM1Solver::on_tick(datetime time,double bid,double ask)
  {
//logger.out_time(time);
//logger.out_rate(bid);
//logger.nl();

   if(time<next_time)
     {
      accumulator.add(bid,ask);
     }
   else
     {
      // обрабатываем все handler'ы по порядку
      for(int i=0; i<MAX_CS_CALLBACKS; i++)
         if(handlers[i]!=NULL)
           {
            handlers[i].on_candle(time,accumulator);
           }

      // сбрасываем свечку в лог
      //logger.out_time(time);
      //logger.out_string(" CS(ohlc):(");
      //logger.out_rate(accumulator.open());
      //logger.comma();
      //logger.out_rate(accumulator.high());
      //logger.comma();
      //logger.out_rate(accumulator.low());
      //logger.comma();
      //logger.out_rate(accumulator.close());
      //logger.out_string_nl(")");

      // подготавливаем аккумулятор к обрабтке следующей свечки
      accumulator.re_init(bid,ask);
      next_time=calc_next_time(time);
     }

  }
//+------------------------------------------------------------------+
//|    Добавляем handler к списку                                    |
//+------------------------------------------------------------------+
bool CandlestickM1Solver::add_on_candle_handler(CandlestickHandler *handler)
  {
   for(int i=0; i<MAX_CS_CALLBACKS; i++)
      if(handlers[i]==NULL)
        {
         handlers[i]=handler;
         return true;         // удачно
        }

   Alert("CandlestickM1solver:\n","Закончилось место в массиве хандлеров\n",
         "Необходимо увеличить MAX_CS_CALLBACKS");
   return false;              // неудачно
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CandlestickM1Solver::calc_next_time(datetime time)
  {
   return (time/M1_PERIOD)*M1_PERIOD+M1_PERIOD;
  }
//+------------------------------------------------------------------+
