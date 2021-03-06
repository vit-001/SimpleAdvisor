//+------------------------------------------------------------------+
//|                                                       Logger.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Files\FileTxt.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Logger:protected CFileTxt
  {
private:

   int               digits;  // количество знаков после запятой для Ask, Bid

public:
                     Logger(string name="");
                    ~Logger(){Close();};

   void out_string(string txt) {WriteString(txt);};
   void out_string_nl(string txt) {WriteString(txt+"\n");};
   void nl() {WriteString("\n");};
   void sp() {WriteString(" ");};
   void comma() {WriteString(",");};
   void semicolon() {WriteString(";");};
   void out_rate(double value) {WriteString(DoubleToString(value,digits));};
   void out_time(datetime time){WriteString(TimeToString(time,TIME_DATE|TIME_SECONDS)); };

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Logger::Logger(string name="")
  {
   string symbol=Symbol(); // текущий символ
   digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // количество знаков после запятой для Ask, Bid

                                                        // подготавливаем имя файла
   string folder_name="SA_log";
   FolderCreate(folder_name);

   string time=TimeToString(TimeCurrent());
   StringReplace(time,":","-");
   StringReplace(time," ","_");
   StringReplace(time,".","-");
   string fname=folder_name+"\\"+name+symbol+"_"+time+".log";

   Open(fname,FILE_WRITE);
   Print("Created log file: ",fname);
  }
//+------------------------------------------------------------------+
