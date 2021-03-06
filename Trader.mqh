//+------------------------------------------------------------------+
//|                                                       Trader.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "TradeAllower.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trader
  {
private:
   // исходные

   TradeAllower     *tr_allower;
   int               losses_in_a_row;
   double            tp_to_sl_rate;
   double            tp_to_spread_rate;
   int               sl_max_series;
   double            test_multiplyer;

public:
   //  конструктор и деструктор
                     Trader(TradeAllower &ta,double TPtoSLrate,double TPtoSpreadRate,int SLmaxSeries,double multiplyer);
                    ~Trader();

   //uint              retcode;
   //ulong             order_ticket;
   //ulong             position;

   // модуль торговли
   long              leverage;
   double            stop_out;

   bool              buy();
   bool              sell();

private:
   void              setup_trade_data();
   double            calculate_order_volume(ENUM_ORDER_TYPE action,double price,double sl_price);
   double            round_volume(double volume);

   //   модуль статистики
private:
   int               full_trades;
   int               test_trades;

   void              setup_statistic();
   void              print_statistic();
public:
   void              on_loss();
   void              on_profit();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trader::Trader(TradeAllower &ta,double TPtoSLrate,double TPtoSpreadRate,int SLmaxSeries,double multiplyer)
  {
   tr_allower=GetPointer(ta);

   tp_to_sl_rate=TPtoSLrate;
   tp_to_spread_rate=TPtoSpreadRate;
   sl_max_series=SLmaxSeries;
   test_multiplyer=multiplyer;

   setup_trade_data();

//order_ticket=0;
   losses_in_a_row=0;

   full_trades=test_trades=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trader::~Trader()
  {
   Print("Full trades  ",full_trades," test trades ",test_trades);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trader::buy()
  {

   if(tr_allower.is_trade_deined()) return false;

   if(AccountInfoDouble(ACCOUNT_MARGIN)>1.0) return false;


   string sym=Symbol();
   MqlTick tick;
   SymbolInfoTick(sym,tick);

   double ask=tick.ask+0.000032;
   double bid=tick.bid;
   double spread=ask-bid;
   double virtual_spread=0.000082;

   double price=SymbolInfoDouble(sym,SYMBOL_ASK);
   double sl=bid-spread*tp_to_spread_rate/tp_to_sl_rate;
   double tp=ask+spread*tp_to_spread_rate;


//Print(ask," ",bid," ",spread);

   MqlTradeRequest request={0};
   MqlTradeResult result={0};
   MqlTradeCheckResult check={0};

   request.action= TRADE_ACTION_DEAL;
   request.magic = 114;
   request.symbol= sym;

   if(losses_in_a_row>=sl_max_series)
     {
      test_trades++;
      request.volume=round_volume(calculate_order_volume(ORDER_TYPE_BUY,price,sl)*test_multiplyer);
     }
   else
     {
      full_trades++;
      request.volume=round_volume(calculate_order_volume(ORDER_TYPE_BUY,price,sl));
     }
   request.price=price;
   request.deviation=5;

   request.sl = sl;
   request.tp = tp;
   request.type=ORDER_TYPE_BUY;
//request.type_filling=ORDER_FILLING_FOK;

   bool trade=OrderSend(request,result);

   if(!trade)
      PrintFormat("OrderSend error %d",GetLastError());

//order_ticket=result.order;
//Print("Тикет:",result.order);

//PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);

   return trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trader::sell()
  {

   string sym=Symbol();
   MqlTick tick;
   SymbolInfoTick(sym,tick);

   double ask=tick.ask;
   double bid=tick.bid-0.000032;
   double spread=ask-bid;

//Print(ask," ",bid," ",spread);

   MqlTradeRequest request={0};
   MqlTradeResult result={0};
   MqlTradeCheckResult check={0};

   request.action= TRADE_ACTION_DEAL;
   request.magic = 115;
   request.symbol = sym;
   request.volume = 0.1;
   request.price=SymbolInfoDouble(sym,SYMBOL_BID);
   request.deviation=5;

   request.tp = bid-spread*16;
   request.sl = ask+spread*8;
   request.type=ORDER_TYPE_SELL;
//request.type_filling=ORDER_FILLING_FOK;

   bool trade=OrderSend(request,result);

   if(!trade)
      PrintFormat("OrderSend error %d",GetLastError());

   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   PrintFormat("tp=%f sl=%f ",request.tp,request.sl);

   return trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trader::setup_trade_data(void)
  {
   ENUM_ACCOUNT_STOPOUT_MODE stopOutMode=(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   if(stopOutMode!=ACCOUNT_STOPOUT_MODE_PERCENT)
     {
      Alert("StopOut задается не в процентах");
      Alert("Торговля запрещена");
      tr_allower.permanent_forbid();
     }
   leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);
   stop_out=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)/100.0;


   Print("Плечо=",leverage," SO=",stop_out);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trader::calculate_order_volume(ENUM_ORDER_TYPE action,double price,double sl_price)
  {

   double margin;
   if(OrderCalcMargin(action,Symbol(),1.0,price,margin))
     {
      double margin_level=margin/100000.0*leverage;
      double so_reserve=leverage*MathAbs(price-sl_price); // *1.1 - на всякий случай

                                                          // пересчитать доступные средства из валюты депозита в базовую валюту
      double money=1000.0;//AccountInfoDouble(ACCOUNT_MARGIN_FREE);

      double volume=leverage*margin_level*money/(margin_level+stop_out+so_reserve)/100000.0;

      Print(margin_level," ",stop_out," so_reserve=",so_reserve," v=",volume);

      return volume;

     }

   Print("Margin not calc");
   return 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trader::round_volume(double volume)
  {
   double result=MathFloor(volume*100.0)/100.0;
   if(result<0.01)
      return 0.01;
   else return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trader::setup_statistic(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trader::on_profit(void)
  {
   losses_in_a_row=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trader::on_loss(void)
  {
   losses_in_a_row++;
  }
//+------------------------------------------------------------------+
