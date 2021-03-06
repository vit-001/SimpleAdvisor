//+------------------------------------------------------------------+
//|                                               simple_advisor.mq5 |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input int      Base_period=10; // Базовый период (мин)
input int      Start_minute=3; // Стартовая минута
input int      MA_period=14; // Период скользящей средней
input double   SignalMinLevel=5.0; // Уровень сигнала для входа в рынок
input double   TP_to_SL_rate=2.0; // Соотношение TP/SL
input double   TP_to_spread_rate=20.0; // Соотношение TP/spread

input int      SL_max_series=2; // максимальная серия StopLoss до перехода в режим оценки рынка
input double   TestMultiplyer=0.1; // коэффициент объема позиции в тестовом режиме

#include "Candlestick.mqh"
#include "CandlestickM1Solver.mqh"
//#include "MovingAverage.mqh"
#include "Logger.mqh"
#include "ReboundSignal.mqh"
#include "Trader.mqh"
#include "TradeAllower.mqh"
//#include "Grafer.mqh"
#include "Analytics.mqh"


//Logger main_log();
//Grafer graph();
Analytics an();

CandlestickM1Solver cs_solver();
//MovingAverage ma(cs_solver,Base_period*(MA_period+1),main_log);

TradeAllower trade_allower();
Trader main_trader(trade_allower,TP_to_SL_rate,TP_to_spread_rate,SL_max_series,TestMultiplyer);

ReboundSignal rs(cs_solver,an,main_trader,Base_period,Start_minute,MA_period,SignalMinLevel);

double sum_profit=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  //trade_allower.permanent_forbid();
  
//---
   //main_log.out_string_nl("SimpleAdvisor init");
   //graph.comment("Simple Advisor data");
   
   an.on_init();
   
   //graph.add_viewport();
   //graph.add_line("P",1);
   //graph.add_dots("B",0,"marker='^' markersize=10");
   //graph.add_dots("S",0,"marker='v' markersize=10");


//--- выведем всю информацию, доступную из функции AccountInfoInteger() 
   printf("ACCOUNT_LOGIN =  %d",AccountInfoInteger(ACCOUNT_LOGIN)); 
   printf("ACCOUNT_LEVERAGE =  %d",AccountInfoInteger(ACCOUNT_LEVERAGE)); 
   bool thisAccountTradeAllowed=AccountInfoInteger(ACCOUNT_TRADE_ALLOWED); 
   bool EATradeAllowed=AccountInfoInteger(ACCOUNT_TRADE_EXPERT); 
   ENUM_ACCOUNT_TRADE_MODE tradeMode=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE); 
   ENUM_ACCOUNT_STOPOUT_MODE stopOutMode=(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE); 
  
//--- сообщим о возможности совершения торговых операций 
   if(thisAccountTradeAllowed) 
      Print("Торговля для данного счета разрешена"); 
   else 
      Print("Торговля для данного счета запрещена!"); 
  
//--- выясним - можно ли торговать на данном счету экспертами 
   if(EATradeAllowed) 
      Print("Торговля советниками для данного счета разрешена"); 
   else 
      Print("Торговля советниками для данного счета запрещена!"); 
  
//--- выясним тип счета 
   switch(tradeMode) 
     { 
      case(ACCOUNT_TRADE_MODE_DEMO): 
         Print("Это демо счет"); 
         break; 
      case(ACCOUNT_TRADE_MODE_CONTEST): 
         Print("Это конкурсный счет"); 
         break; 
      default:Print("Это реальный счет!"); 
     } 
  
//--- выясним режим задания уровня StopOut 
   switch(stopOutMode) 
     { 
      case(ACCOUNT_STOPOUT_MODE_PERCENT): 
         Print("Уровень StopOut задается в процентах"); 
         break; 
      default:Print("Уровень StopOut задается в денежном выражении"); 
     } 


   Print("Имя брокера = ",AccountInfoString(ACCOUNT_COMPANY));
   Print("Валюта депозита = ",AccountInfoString(ACCOUNT_CURRENCY));
   Print("Имя клиента = ",AccountInfoString(ACCOUNT_NAME));
   Print("Название торгового сервера = ",AccountInfoString(ACCOUNT_SERVER));

   PrintFormat("ACCOUNT_BALANCE = %G",AccountInfoDouble(ACCOUNT_BALANCE));
   PrintFormat("ACCOUNT_CREDIT = %G",AccountInfoDouble(ACCOUNT_CREDIT));
   PrintFormat("ACCOUNT_PROFIT = %G",AccountInfoDouble(ACCOUNT_PROFIT));
   PrintFormat("ACCOUNT_EQUITY = %G",AccountInfoDouble(ACCOUNT_EQUITY));
   PrintFormat("ACCOUNT_MARGIN = %G",AccountInfoDouble(ACCOUNT_MARGIN));
   PrintFormat("ACCOUNT_FREEMARGIN = %G",AccountInfoDouble(ACCOUNT_FREEMARGIN));
   PrintFormat("ACCOUNT_MARGIN_LEVEL = %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   PrintFormat("ACCOUNT_MARGIN_SO_CALL = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   PrintFormat("ACCOUNT_MARGIN_SO_SO = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));


   ObjectCreate(0,"test",OBJ_TREND,0,TimeCurrent(),1.1,TimeCurrent()+100*24*3600,1.2);
   ObjectSetInteger(0,"test",OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(0,"test",OBJPROP_RAY_RIGHT,false);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
   an.on_de_init();

   Print("Общий профит=",sum_profit);

//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTick tick;

   SymbolInfoTick(Symbol(),tick);
   
   
   trade_allower.on_tick(tick.time);
   cs_solver.on_tick(tick.time,tick.bid,tick.ask);

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+ 
//| TradeTransaction function                                        | 
//+------------------------------------------------------------------+ 
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

   static double open_price;

   if(trans.type==TRADE_TRANSACTION_DEAL_ADD) // добавлена сделка
     {
      if(is_open_deal(trans.order_type,trans.deal_type))
        {
         Print("Открываем позицию ",trans.deal," по цене ",trans.price);
         open_price=trans.price;
         //graph.plot("P",TimeCurrent(),sum_profit);
         //graph.plot("B",TimeCurrent(),trans.price);
        }
      else
        {
         Print("Закрываем позицию ",trans.position," по цене ",trans.price);
         if(trans.order_type==ORDER_TYPE_BUY)
           {
            double profit=trans.price-open_price;

            MqlTick tick;
            SymbolInfoTick(trans.symbol,tick);

            sum_profit+=(profit*trans.volume*100000.0-trans.volume*3.2)/tick.bid; //ask - под вопросом
            //graph.plot("P",TimeCurrent(),sum_profit);
            //graph.plot("S",TimeCurrent(),trans.price);
            if(profit>0.0)
              {
               Print("Profit=",profit*trans.volume*100000.0);
               main_trader.on_profit();
              }
            else
              {
               Print("Loss=",-profit*trans.volume*100000.0);
               main_trader.on_loss();
              }

           }
         else
           {
           }
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_open_deal(ENUM_ORDER_TYPE order_type,ENUM_DEAL_TYPE deal_type)
  {
   if(order_type==ORDER_TYPE_BUY && deal_type==DEAL_TYPE_BUY) return true;
   if(order_type==ORDER_TYPE_SELL && deal_type==DEAL_TYPE_SELL) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {

   return rs.max_signal_count;
  }
//+------------------------------------------------------------------+
