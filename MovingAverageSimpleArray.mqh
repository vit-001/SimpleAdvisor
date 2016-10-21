//+------------------------------------------------------------------+
//|                                     MovingAverageSimpleArray.mqh |
//|                                  Copyright 2016, Vitaliy Nikitin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vitaliy Nikitin"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MovingAverageSimpleArray
  {
private:
   double            data[];
   int               valid_n;

public:
                     MovingAverageSimpleArray(int dimension);
                    ~MovingAverageSimpleArray();

   void              add(double value);

   double            ma(int duration);
   double            lma(int duration);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAverageSimpleArray::add(double value)
  {
   for(int i=ArraySize(data)-1; i>0; i--)
      data[i]=data[i-1];
   data[0]=value;
   valid_n++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MovingAverageSimpleArray::ma(int duration)
  {
   int valid_period=MathMin(ArraySize(data),valid_n);
   if(duration>valid_period)
      duration=valid_period;

   double temp=0.0;

   for(int i=0; i<duration; i++)
      temp+=data[i];

   return temp/duration;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MovingAverageSimpleArray::lma(int duration)
  {
   int valid_period=MathMin(ArraySize(data),valid_n);
   if(duration>valid_period)
      duration=valid_period;

   if(duration<1) return 0.0;

   double temp=0.0;

   for(int i=0; i<duration; i++)
      temp+=data[i]*(duration-i);

   return 2.0*temp/(duration*(duration+1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageSimpleArray::MovingAverageSimpleArray(int dimension)
  {
   ArrayResize(data,dimension);
   ArrayInitialize(data,0.0);
   valid_n=0;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageSimpleArray::~MovingAverageSimpleArray()
  {
   ArrayFree(data);
  }
//+------------------------------------------------------------------+
