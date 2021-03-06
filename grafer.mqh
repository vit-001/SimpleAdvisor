//+------------------------------------------------------------------+
//|                                                       grafer.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Candlestick.mqh"
#include "Logger.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Grafer:private Logger
  {
private:
   int               digits;  // количество знаков после запятой для Ask, Bid

public:
                     Grafer();
                    ~Grafer();

   void              comment(string txt){out_string_nl("#"+txt);};
   void              add_viewport(){out_string_nl("AVP");};
   void              add_candle(string plot_name,int viewport)
     {
      out_string_nl("ACS("+plot_name+")"+IntegerToString(viewport));
     };
   void              add_line(string plot_name,int viewport)
     {
      out_string_nl("AG("+plot_name+")"+IntegerToString(viewport));
     };
   void              add_dots(string plot_name,int viewport, string options="")
     {
      out_string_nl("AD("+plot_name+")"+IntegerToString(viewport)+":"+options);
     };
   void              plot(string plot_name,datetime t,double value)
     {
     out_string("("+plot_name+"):");
     out_time(t);
     semicolon();
     out_rate(value);
     nl();
     };
   void              plot(string plot_name,datetime t,Candlestick &candle)
     {
     out_string("CS("+plot_name+"):");
     out_time(t);
     semicolon();
     out_rate(candle.open());
     semicolon();
     out_rate(candle.high());
     semicolon();
     out_rate(candle.low());
     semicolon();
     out_rate(candle.close());
     semicolon();          
     nl();
     };

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Grafer::Grafer()
  {
   string symbol=Symbol(); // текущий символ
   digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // количество знаков после запятой для Ask, Bid

                                                        // подготавливаем имя файла
   string folder_name="SA_log";
   FolderCreate(folder_name);

   string fname=folder_name+"\\"+"grafx.dat";

   Open(fname,FILE_WRITE);
   Print("Created graph file: ",fname);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Grafer::~Grafer()
  {
   Close();
  }

//+------------------------------------------------------------------+
