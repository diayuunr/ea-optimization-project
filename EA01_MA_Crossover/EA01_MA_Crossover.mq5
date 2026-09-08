//+------------------------------------------------------------------+
//|                                            EA01_MA_Crossover.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade trade;

//--- Input parameters
input int    FastMAPeriod = 20;
input int    SlowMAPeriod = 50;

input ENUM_MA_METHOD MAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;

input double LotSize = 0.01;
input int    StopLossPoints = 0;
input int    TakeProfitPoints = 0;

input ulong  MagicNumber = 10001;

//--- Moving Average handles
int fastMAHandle;
int slowMAHandle;

//--- Untuk mendeteksi candle baru
datetime lastBarTime = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Membuat indikator Fast MA
   fastMAHandle = iMA(
      _Symbol,
      _Period,
      FastMAPeriod,
      0,
      MAMethod,
      AppliedPrice
   );

   // Membuat indikator Slow MA
   slowMAHandle = iMA(
      _Symbol,
      _Period,
      SlowMAPeriod,
      0,
      MAMethod,
      AppliedPrice
   );

   // Cek apakah indikator berhasil dibuat
   if(fastMAHandle == INVALID_HANDLE ||
      slowMAHandle == INVALID_HANDLE)
   {
      Print("Gagal membuat Moving Average.");
      return(INIT_FAILED);
   }

   // Magic number untuk EA ini
   trade.SetExpertMagicNumber(MagicNumber);

   Print("EA01 MA Crossover berhasil diinisialisasi.");
   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Hapus indicator handle
   if(fastMAHandle != INVALID_HANDLE)
      IndicatorRelease(fastMAHandle);

   if(slowMAHandle != INVALID_HANDLE)
      IndicatorRelease(slowMAHandle);
  }
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Hanya menjalankan logika sekali setiap candle baru
   datetime currentBarTime = iTime(_Symbol, _Period, 0);

   if(currentBarTime == lastBarTime)
      return;

   lastBarTime = currentBarTime;


   //--- Array untuk menyimpan nilai MA
   double fastMA[3];
   double slowMA[3];

   // Ambil nilai MA
   if(CopyBuffer(fastMAHandle, 0, 0, 3, fastMA) < 3)
      return;

   if(CopyBuffer(slowMAHandle, 0, 0, 3, slowMA) < 3)
      return;


   // Candle yang sudah selesai:
   // index 1 = candle terakhir yang sudah close
   // index 2 = candle sebelumnya

   double fastPrevious = fastMA[2];
   double slowPrevious = slowMA[2];

   double fastCurrent = fastMA[1];
   double slowCurrent = slowMA[1];


   //===============================================================
   // BUY SIGNAL
   // Fast MA sebelumnya berada di bawah/di sama dengan Slow MA
   // kemudian Fast MA berada di atas Slow MA
   //===============================================================

   bool buySignal =
      (fastPrevious <= slowPrevious &&
       fastCurrent > slowCurrent);


   //===============================================================
   // SELL SIGNAL
   // Fast MA sebelumnya berada di atas/di sama dengan Slow MA
   // kemudian Fast MA berada di bawah Slow MA
   //===============================================================

   bool sellSignal =
      (fastPrevious >= slowPrevious &&
       fastCurrent < slowCurrent);


   //--- BUY
   if(buySignal)
   {
      // Tutup posisi berlawanan
      CloseSellPositions();

      if(!HasBuyPosition())
      {
         OpenBuy();
      }
   }


   //--- SELL
   if(sellSignal)
   {
      // Tutup posisi berlawanan
      CloseBuyPositions();

      if(!HasSellPosition())
      {
         OpenSell();
      }
   }
}


//+------------------------------------------------------------------+
//| Open BUY                                                         |
//+------------------------------------------------------------------+
void OpenBuy()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double sl = 0;
   double tp = 0;

   if(StopLossPoints > 0)
      sl = ask - StopLossPoints * _Point;

   if(TakeProfitPoints > 0)
      tp = ask + TakeProfitPoints * _Point;

   trade.Buy(
      LotSize,
      _Symbol,
      ask,
      sl,
      tp,
      "MA Crossover BUY"
   );
}


//+------------------------------------------------------------------+
//| Open SELL                                                        |
//+------------------------------------------------------------------+
void OpenSell()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double sl = 0;
   double tp = 0;

   if(StopLossPoints > 0)
      sl = bid + StopLossPoints * _Point;

   if(TakeProfitPoints > 0)
      tp = bid - TakeProfitPoints * _Point;

   trade.Sell(
      LotSize,
      _Symbol,
      bid,
      sl,
      tp,
      "MA Crossover SELL"
   );
}


//+------------------------------------------------------------------+
//| Check BUY position                                               |
//+------------------------------------------------------------------+
bool HasBuyPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         return true;
      }
   }

   return false;
}


//+------------------------------------------------------------------+
//| Check SELL position                                              |
//+------------------------------------------------------------------+
bool HasSellPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
      {
         return true;
      }
   }

   return false;
}


//+------------------------------------------------------------------+
//| Close BUY positions                                              |
//+------------------------------------------------------------------+
void CloseBuyPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         trade.PositionClose(ticket);
      }
   }
}


//+------------------------------------------------------------------+
//| Close SELL positions                                             |
//+------------------------------------------------------------------+
void CloseSellPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
      {
         trade.PositionClose(ticket);
      }
   }
}
//+------------------------------------------------------------------+