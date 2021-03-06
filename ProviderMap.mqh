//+------------------------------------------------------------------+
//|                                                  ProviderMap.mqh |
//|                        Copyright 2016, BlackSteel, FairForex.org |
//|                                            https://fairforex.org |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, BlackSteel, FairForex.org"
#property link      "https://fairforex.org"
#property strict

               
class Map {
   public:
      int key[];
      int value[];
      int status[];
      int count;
      int iterator;
      bool changed;
      bool autosave;
      string filename;
      
      Map(void) {
         count = 0;
         changed = false;
         autosave = false;
      }
      
      Map(int size, string _filename = "") {
         ArrayResize(key, size);
         ArrayResize(value, size);
         ArrayResize(status, size);
         count = 0;
         changed = false;
         filename = _filename;
         if (filename != "")
            autosave = true;
      }
      
      void ticktack() {
         changed = !changed;
         iterator = 0;
      }
      
      int getValue(int k) {
         for (int i=0; i<count; i++) {
            if (key[i] == k) return value[i];
         }
         return -1;
      }
      
      int getKey(int v) {
         for (int i=0; i<count; i++) {
            if (value[i] == v) return key[i];
         }
         return -1;
      }

      void set(int k, int v) {
         for (int i=0; i<count; i++) {
            if (key[i] == k) {
               value[i] = v;
               status[i] = changed;
               return;
            }
         }
         //if (count>=ArraySize(key))
            //audit();
         key[count] = k;
         value[count] = v;
         status[count] = changed;
         count++;
         if (autosave) save();
      } //set
      
      void del(int k) {
         for (int i=0; i<count; i++) {
            if (key[i] == k) {
               if (i != count -1) {
                  key[i]   = key[count-1];
                  value[i] = value[count-1];
                  status[i] = status[count-1];
               }
               count--;
               return;
            }
         }
      } //del
      void del_index(int i) {
         if (i != count -1) {
            key[i]   = key[count-1];
            value[i] = value[count-1];
            status[i] = status[count-1];
         }
         count--;
      }
      int key_restore(string s, int t) {
         string res[3];
         StringSplit(s, '_', res);
         int mt = (int)StringToInteger(res[1]);
         set(t, mt);
         Print("key: ", t, " restored with master: ", mt);
         return mt;
      }
      void save(string s="") {
         if (s!="") filename = s;
         ResetLastError();
         int handle=FileOpen(filename, FILE_WRITE|FILE_BIN);
         if(handle!=INVALID_HANDLE) {
            FileWriteInteger(handle, count);
            FileWriteArray(handle, key, 0, count);
            FileWriteArray(handle, value, 0, count);
            FileClose(handle);
            Print("Map saved, count: ", count);
           }
         else
            Print("Failed to open the file, error ",GetLastError());
      } // end save
      void load(string s="") {
         if (s!="") filename = s;
         ResetLastError();
         int handle=FileOpen(filename, FILE_READ|FILE_BIN);
         if(handle!=INVALID_HANDLE) {
            count = FileReadInteger(handle);
            FileReadArray(handle, key, 0, count);
            FileReadArray(handle, value, 0, count);
            FileClose(handle);
            Print("Map loaded, count: ", count);
           }
         else
            Print("Failed to open the file, error ",GetLastError());
      } // end load
      void audit() {
         int j=0;
         while (j<count) {
            if (!OrderSelect(key[j], SELECT_BY_TICKET) || OrderCloseTime() > 0) 
               del_index(j);
            else
               j++;
         } 
      }
      int checkOnClose() {
         for (int i=iterator; i<count; i++) {
            if (status[i] != changed && !OrderSelect(key[i], SELECT_BY_TICKET) || OrderCloseTime() > 0){
               iterator = i;
               int res = key[i];
               del_index(i);
               return res;
            }
         }
         return 0;
      }
}; //end class Map

#define PROVIDER_COUNT 24

int providerMap[PROVIDER_COUNT] = {0, //Пустышка для ручных мэджиков
                     1555139, //Lotgenoten         1  G-Lot
                     1489427, //LongVision         2  LongWay
                     1783508, //ATLAS(Tickmill)    3  Salt  
                     1575836, //FX BSR             4  RSB
                     1544275, //RainMaker          5  Train
                     1648483, //NewTrading         6  NewWay
                     1792305, //ForexInvesting     7  ForInvest
                     1045415, //LuckyPound         8  LuckyLuck
                     924130,  //iQuantFX           9  Quantum
                     1550372, //PepperStone        10 Stone
                     1593142, //SignalFX-1         11 Formula
                     1954086, //Scorpion           12 Escort
                     0,
                     14,      //CALM               14 BlackDigger
                     1771823, //Premium Trading BB 15 Premiera
                     1346753, //NinjaTrainer       16 NightTrain
                     1627564, //Vine               17 Shato
                     1505363, //VolcanoFXEA        18 Pompea
                     1502461, //ASTA Light         19 Astra
                     1974505, //4000K              20 HDFX
                     1094363, //Steady Profit      21 Harvard
                     691405,  //Robin VOL portfolio 22 RobinGood
                     0};
string providerName[PROVIDER_COUNT] = {"Manual",
                     "G-Lot",
                     "LongWay",
                     "Salt",
                     "RSB",
                     "Train",
                     "NewWay",
                     "ForInvest",
                     "LuckyLuck",
                     "Quantum",
                     "Stone",
                     "Formula",
                     "Escort",
                     "",
                     "Digger",
                     "Premiera",
                     "NightTrain",
                     "Shato",
                     "Pompea",
                     "Astra",
                     "HDFX",
                     "Harvard",
                     "RobinGood",
                     ""};

int getProviderIndex(int p) {
   for (int i = 1; i<PROVIDER_COUNT; i++) {
      if (providerMap[i] == p) return i;
   }
   return -1;
}

double providerWeight[PROVIDER_COUNT] = {0};

//string providerName[PROVIDER_COUNT] = {};
