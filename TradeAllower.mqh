//+------------------------------------------------------------------+
//|                                                 TradeAllower.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define MONDAY_START_HOUR (3)
#define FRIDAY_STOP_HOUR (21)
#define PAUSE_TIME (60*60*3)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradeAllower
  {
private:
   datetime          last_time;
   datetime          deined_time;
   bool              permanent_deined;

public:

                     TradeAllower();
                    ~TradeAllower();

   void              on_tick(datetime time);
   bool              is_trade_deined();
   void              pause(int second);
   void              permanent_forbid();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeAllower::TradeAllower()
  {
   last_time=deined_time=0;
   permanent_deined=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeAllower::~TradeAllower()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeAllower::on_tick(datetime time)
  {
   if(time-last_time>60)
      pause(PAUSE_TIME);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TradeAllower::is_trade_deined(void)
  {
   if(permanent_deined)
      return true;

   MqlDateTime mtime;
   datetime time=TimeCurrent();

   TimeToStruct(time,mtime);

   if(mtime.day_of_week==1 && mtime.hour<=MONDAY_START_HOUR)
     {
      Print("ѕќЌ≈ƒ≈Ћ№Ќ» ");
      return true;
     }

   if(mtime.day_of_week==5 && mtime.hour>=FRIDAY_STOP_HOUR)
     {
      Print("ѕя“Ќ»÷ј");
      return true;
     }

// todo: добавить анализ паузы по отсутствию данных

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeAllower::pause(int second)
  {
   deined_time=TimeCurrent()+second;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeAllower::permanent_forbid(void)
  {
   permanent_deined=true;
  }

//+------------------------------------------------------------------+
