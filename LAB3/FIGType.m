function [] = FIGType(FrameNr,BlockNr,Type,FIGDataLength,Data)

Extension = BintoDez(Data(4:8),5);

switch Type
% ------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------
    case 0
        CN=Data(1);
        OE=Data(2);
        PD=Data(3);
        switch Extension
% ------------------------------------------------------------------------------------------------------------------------------    
            case 0                                                                                       
                pos = 9;
                
                EId = BintoDez(Data(pos:pos+15),16);
                ChangeFlag = BintoDez(Data(pos+16:pos+17),2);
                ALFlag = BintoDez(Data(pos+8),1);
                CIFCount = BintoDez(Data(pos+9:pos+13),5)*250 + BintoDez(Data(pos+14:pos+21),8);
                OccurenceChange = BintoDez(Data(pos+22:pos+29),8);
                
                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d EId: %5d ChangeFlag: %1d ALFlag: %1d CIFCount: %5d OccurenceChange: %3d'...
                                 ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,EId,ChangeFlag,ALFlag,CIFCount,OccurenceChange));
                
% ------------------------------------------------------------------------------------------------------------------------------    
            case 1                                                                                         
                pos = 9;
                darstellen = 1;
                while pos<length(Data)
                    SubChID = BintoDez(Data(pos:pos+5),6);
                    StartAdress = BintoDez(Data(pos+6:pos+15),10);
                    
                    if Data(pos+16) == 1                                                              
                        
                        SubChannelSize = BintoDez(Data(pos+22:pos+31),10);
                        ProtLevel = BintoDez(Data(pos+20:pos+21),2) + 1;
                        if Data(pos+20) == 1
                            if darstellen == 1
                                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SubChID: %2d StartAdr:%4d EEP ProtLevel: %1d-A SubChSize: %3d'...
                                          ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SubChID,StartAdress,ProtLevel,SubChannelSize));
                                darstellen = 0;
                            else
                                disp(sprintf('                                                               SubChID: %2d StartAdr:%4d EEP ProtLevel: %1d-A SubChSize: %3d'...
                                          ,SubChID,StartAdress,ProtLevel,SubChannelSize));
                            end
                        else
                            if darstellen == 1
                                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SubChID: %2d StartAdr:%4d EEP ProtLevel: %1d-B SubChSize: %3d'...
                                          ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SubChID,StartAdress,ProtLevel,SubChannelSize));
                                darstellen = 0;
                            else
                                disp(sprintf('                                                               SubChID: %2d StartAdr:%4d EEP ProtLevel: %1d-B SubChSize: %3d'...
                                          ,SubChID,StartAdress,ProtLevel,SubChannelSize));
                            end
                        end
                        pos = pos + 32;
                        
                    else                                                                                    
                        TabelIndexNr = BintoDez(Data(pos+18:pos+23),6);                                     
                        [SubChannelSize, ProtLevel, Rate]=TabelIndex(TabelIndexNr);                         
                        if darstellen == 1
                            disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SubChID: %2d StartAdr:%4d UEP ProtLevel: %1d   SubChSize: %3d BitRate: %3d'...
                                          ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SubChID,StartAdress,ProtLevel,SubChannelSize,Rate));
                            darstellen = 0;
                        else
                            disp(sprintf('                                                               SubChID: %2d StartAdr:%4d UEP ProtLevel: %1d   SubChSize: %3d BitRate: %3d'...
                                          ,SubChID,StartAdress,ProtLevel,SubChannelSize,Rate));
                        end
                        pos = pos + 24;
                    end
                end
% ------------------------------------------------------------------------------------------------------------------------------    
            case 2                                                                          
                pos = 9;
                darstellen = 1;
                while pos<length(Data)
                    if PD == 1                                                              
                        SId = BintoDez(Data(pos:pos+31),32);                                
                        LocalFlag = Data(32);
                        NbrServiceComponents = BintoDez(Data(pos+36:pos+39),4);
                        pos = pos + 40;
                    else                                                                    
                        SId = BintoDez(Data(pos:pos+15),16);                                
                        LocalFlag = Data(16);
                        NbrServiceComponents = BintoDez(Data(pos+20:pos+23),4);
                        pos = pos + 24;
                    end
                    
                    for k=0:NbrServiceComponents-1
                        TMId = BintoDez(Data(pos:pos+1),2);                                        
                        PS = Data(pos+14);
                        CAFlag = Data(pos+15);
                        switch TMId
                            case 0                                                                 
                                ASCTy = BintoDez(Data(pos+2:pos+7),6);                             
                                SubChId = BintoDez(Data(pos+8:pos+13),6);
                                
                                if darstellen == 1
                                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d MSC stream audio ASCTy: %2d SubChId: %2d P/S: %1d CAFlag: %1d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,ASCTy,SubChId,PS,CAFlag));
                                    darstellen = 0;
                                else
                                    disp(sprintf('                                                               SId: %5d MSC stream audio ASCTy: %2d SubChId: %2d P/S: %1d CAFlag: %1d'...
                                              ,SId,ASCTy,SubChId,PS,CAFlag));
                                end
                                
                            case 1                                                                      
                                DSCTy = BintoDez(Data(pos+2:pos+7),6);                                  
                                SubChId = BintoDez(Data(pos+8:pos+13),6);
                                
                                if darstellen == 1
                                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d MSC stream data DSCTy: %2d SubChId: %2d P/S: %1d CAFlag: %1d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,DSCTy,SubChId,PS,CAFlag));
                                    darstellen = 0;
                                else
                                    disp(sprintf('                                                               SId: %5d MSC stream data DSCTy: %2d SubChId: %2d P/S: %1d CAFlag: %1d'...
                                              ,SId,DSCTy,SubChId,PS,CAFlag));
                                end
                                
                            case 2                                                                      
                                DSCTy = BintoDez(Data(pos+2:pos+7),6);                                  
                                FIDCid = BintoDez(Data(pos+8:pos+13),6);
                                
                                if darstellen == 1
                                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d FIDC DSCTy: %2d FIDCid: %2d P/S: %1d CAFlag: %1d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,DSCTy,FIDCid,PS,CAFlag));
                                    darstellen = 0;
                                else
                                    disp(sprintf('                                                               SId: %5d FIDC DSCTy: %2d FIDCid: %2d P/S: %1d CAFlag: %1d'...
                                              ,SId,DSCTy,FIDCid,PS,CAFlag));
                                end
                                
                            otherwise                                                                   
                                SCId = BintoDez(Data(pos+2:pos+13),12);                                 
                                if darstellen == 1
                                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d MSC packet data SCId: %4d P/S: %1d CAFlag: %1d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,SCId,PS,CAFlag));
                                    darstellen = 0;
                                else
                                    disp(sprintf('                                                               SId: %5d MSC packet data SCId: %4d P/S: %1d CAFlag: %1d'...
                                              ,SId,SCId,PS,CAFlag));
                                end
                                
                        end
                        
                        pos = pos + 16;
                    end
                end
                
                
% ------------------------------------------------------------------------------------------------------------------------------                   
            case 5                                                                                             
                pos = 9;                                                                                       
                darstellung = 1;                    
                while pos<length(Data)                                                                         
                    if Data(pos) == 1                                                                          
                        SCId = BintoDez(Data(pos+5:pos+16),12);                                                
                        Sprache = LanguagesCodeTables(BintoDez(Data(pos+16:pos+23),8));                        
                        
                        if darstellung == 1
                            disp([sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SCId: %2d '...
                                          ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SCId) Sprache]);
                            darstellung = 0;
                        else
                            disp([sprintf('                                                               SCId: %2d '...
                                          ,SCId) Sprache]);
                        end
                        pos = pos + 24;
                    else                                                                                       
                        Id=BintoDez(Data(pos+2:pos+7),6);
                        Sprache = LanguagesCodeTables(BintoDez(Data(pos+8:pos+15),8));
                        if Data(pos+1)==0
                            if darstellung == 1
                                disp([sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d MSC Stream SubChId: %2d '...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,Id) Sprache]);
                                darstellung = 0;
                            else
                                disp([sprintf('                                                               MSC Stream SubChId: %2d '...
                                              ,Id) Sprache]);
                            end
                        else
                            if darstellung == 1
                                disp([sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d FIC FIDCId: %2d '...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,Id) Sprache]);
                                darstellung = 0;
                            else
                                disp([sprintf('                                                               FIC FIDCId: %2d '...
                                              ,Id) Sprache]);
                            end
                        end
                        
                        pos = pos + 16;
                    end
                end
% ------------------------------------------------------------------------------------------------------------------------------                
            case 6                                                                                             
                pos = 9;
                darstellung = 1;                  
                while pos<length(Data)
                
                    LA = Data(pos+1);
                    SH = Data(pos+2);
                    ILS = Data(pos+3);
                    LSN = BintoDez(Data(pos+4:pos+15),12);

                    if Data(pos) == 1                                                    

                        if PD == 0                                                           
                            IdLQ = BintoDez(Data(pos+17:pos+18),2);
                            Shd = Data(pos+19);
                            NbrOfIds = BintoDez(Data(pos+20:pos+23),4);

                            pos = pos + 24;

                            if ILS == 0                                                     
                                for b=1:NbrOfIds
                                    Id = BintoDez(Data(pos:pos+15),16);

                                    if darstellung == 1
                                        disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d LA: %1d S/H: %1d ILS: %1d LSN: %4d IdLQ: %1d Shd: %1d Id: %5d'...
                                                      ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,LA,SH,ILS,LSN,IdLQ,Shd,Id));
                                        darstellung = 0;
                                    else
                                        disp(sprintf('                                                               LA: %1d S/H: %1d ILS: %1d LSN: %4d IdLQ: %1d Shd: %1d Id: %5d'...
                                                      ,LA,SH,ILS,LSN,IdLQ,Shd,Id));
                                    end

                                    pos = pos + 16;
                                end
                            else                                                            
                                for b=1:NbrOfIds
                                    ECC = BintoDez(Data(pos:pos+7),8);
                                    Id = BintoDez(Data(pos+8:pos+23),16);

                                    if darstellung == 1
                                        disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d LA: %1d S/H: %1d ILS: %1d LSN: %4d IdLQ: %1d Shd: %1d ECC: %3d Id: %5d'...
                                                      ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,LA,SH,ILS,LSN,IdLQ,Shd,ECC,Id));
                                        darstellung = 0;
                                    else
                                        disp(sprintf('                                                               LA: %1d S/H: %1d ILS: %1d LSN: %4d IdLQ: %1d Shd: %1d ECC: %3d Id: %5d'...
                                                      ,LA,SH,ILS,LSN,IdLQ,Shd,ECC,Id));
                                    end

                                    pos = pos + 24;
                                end
                            end

                        else                                                                 
                            for b=1:NbrOfIds
                                SId = BintoDez(Data(pos:pos+31),32);

                                if darstellung == 1
                                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d LA: %1d S/H: %1d ILS: %1d LSN: %4d IdLQ: %1d Shd: %1d SId: %10d'...
                                                  ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,LA,SH,ILS,LSN,IdLQ,Shd,SId));
                                    darstellung = 0;
                                else
                                    disp(sprintf('                                                               LA: %1d S/H: %1d ILS: %1d LSN: %4d IdLQ: %1d Shd: %1d SId: %10d'...
                                                  ,LA,SH,ILS,LSN,IdLQ,Shd,SId));
                                end

                                pos = pos + 32;
                            end
                        end


                    else                                                                     
                        if darstellung == 1
                            disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d LA: %1d S/H: %1d ILS: %1d LSN: %4d'...
                                          ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,LA,SH,ILS,LSN));
                            darstellung = 0;
                        else
                            disp(sprintf('                                                               LA: %1d S/H: %1d ILS: %1d LSN: %4d'...
                                          ,LA,SH,ILS,LSN));
                        end
                        pos = pos + 16;
                    end
                end
                
                
                
% ------------------------------------------------------------------------------------------------------------------------------                
            case 8                                                                                            
                pos = 9;
                darstellen = 1;                    
                while pos<length(Data)
                    if PD == 1
                        SId = BintoDez(Data(pos:pos+31),32);
                        pos = pos + 32;
                    else
                        SId = BintoDez(Data(pos:pos+15),16);
                        pos = pos + 16;
                    end
                    
                    ExtFlag = Data(pos);
                    SCIdS = BintoDez(Data(pos+4:pos+7),4);
                    
                    if Data(pos+8) == 1                                  
                        SCId = BintoDez(Data(pos+12:pos+23),12);
                        
                        if darstellen == 1
                            disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d ExtFlag: %1d SCIdS: %2d SCId: %4d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,ExtFlag,SCIdS,SCId));
                            darstellen = 0;
                        else
                            disp(sprintf('                                                               SId: %5d ExtFlag: %1d SCIdS: %2d'...
                                              ,SId,ExtFlag,SCIdS,SCId));
                        end
                        
                        
                        pos = pos + 32;
                    else
                        if Data(pos+9) == 1                                                                      
                            FIDCId = BintoDez(Data(pos+10:pos+15),6);
                            
                            if darstellen == 1
                            	disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d ExtFlag: %1d SCIdS: %2d FIC FIDCId: %2d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,ExtFlag,SCIdS,FIDCId));
                            	darstellen = 0;
                            else
                            	disp(sprintf('                                                               SId: %5d ExtFlag: %1d SCIdS: %2d FIC FIDCId: %2d'...
                                              ,SId,ExtFlag,SCIdS,FIDCId));
                            end
                            
                        else
                            SubChId = BintoDez(Data(pos+10:pos+15),6);
                            
                            if darstellen == 1
                            	disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d ExtFlag: %1d SCIdS: %2d MSC in Stream mode SubChId: %2d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,ExtFlag,SCIdS,SubChId));
                            	darstellen = 0;
                            else
                            	disp(sprintf('                                                               SId: %5d ExtFlag: %1d SCIdS: %2d MSC in Stream mode SubChId: %2d'...
                                              ,SId,ExtFlag,SCIdS,SubChId));
                            end
                        end
                        pos = pos + 24;
                    end
                    if ExtFlag == 0;pos = pos - 8;end                
                end
                
% ------------------------------------------------------------------------------------------------------------------------------                
            case 9                                                                                            
                LTO = 0.5* BintoDez(Data(12:16),5);
                if Data(11) == 1,LTO=LTO*-1;end
                ECC = BintoDez(Data(17:24),8);
                InterTableId = BintoDez(Data(25:32),8);

                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d LTO: %+3.1fh ECC: %3d InterTabId: %1d'...
                        ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,LTO,ECC,InterTableId));
% ------------------------------------------------------------------------------------------------------------------------------
            case 10                                                                                            
                MJD = BintoDez(Data(10:26),17);
                [Y,M,D] = mJulianDate(MJD);
                if FIGDataLength == 5                                                                          
                    hour = BintoDez(Data(30:34),5);
                    min = BintoDez(Data(35:40),6);

                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d Date: %04d/%02d/%02d Time: %02d:%02d UTC'...
                        ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,Y,M,D,hour,min));
                else                                                                                         
                    hour = BintoDez(Data(30:34),5);
                    min = BintoDez(Data(35:40),6);
                    sec = BintoDez(Data(41:46),6);
                    millsec = BintoDez(Data(47:56),10);

                    disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d Date: %04d/%02d/%02d Time: %02d:%02d:%02:%03 UTC'...
                        ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,Y,M,D,hour,min,sec,millsec));
                end
% ------------------------------------------------------------------------------------------------------------------------------
            case 13                                                                                            
                pos = 9;
                darstellen = 1;                     
                while pos<length(Data)
                    if PD == 1;
                        SId = BintoDez(Data(pos:pos+31),30);
                        pos = pos + 32;
                    else
                        SId = BintoDez(Data(pos:pos+15),16);
                        pos = pos + 16;
                    end
                    
                    SCIdS = BintoDez(Data(pos:pos+3),4);
                    NbrOfApp = BintoDez(Data(pos+4:pos+7),4);
                    pos = pos + 8;
                    
                    for v=1:NbrOfApp
                        UsrAppType = BintoDez(Data(pos:pos+10),11);
                        UsrAppDataLength = BintoDez(Data(pos+11:pos+15),5);
                        
                        if UsrAppDataLength > 0
                            CAFlag = Data(pos+16);
                            XPADAppTy = BintoDez(Data(pos+19:pos+23),5);
                            DGFlag = Data(pos+24);
                            DSCTy = BintoDez(Data(pos+26:pos+31),6);

                            if darstellen == 1
                                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d SCIdS: %2d UsrAppType: %4d CAFlag: %1d XPApTy: %2d DGFlag: %1d DSCTy: %2d'...
                                                  ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,SCIdS,UsrAppType,CAFlag,XPADAppTy,DGFlag,DSCTy));
                                darstellen = 0;
                            else
                                disp(sprintf('                                                               SId: %5d SCIdS: %2d UsrAppType: %4d CAFlag: %1d XPApTy: %2d DGFlag: %1d DSCTy: %2d'...
                                                  ,SId,SCIdS,UsrAppType,CAFlag,XPADAppTy,DGFlag,DSCTy));
                            end
                            
                        else
                            if darstellen == 1
                                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d SCIdS: %2d UsrAppType: %4d'...
                                                  ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,SCIdS,UsrAppType));
                                darstellen = 0;
                            else
                                disp(sprintf('                                                               SId: %5d SCIdS: %2d UsrAppType: %4d'...
                                                  ,SId,SCIdS,UsrAppType));
                            end
                        end
                            
                        pos = UsrAppDataLength*8 + 16 + pos;
                    end
                    
                end
                
 % ------------------------------------------------------------------------------------------------------------------------------
            case 17                                                                                           
                pos = 9;
                darstellen = 1;                                                             
                while pos<length(Data)
                
                    SId = BintoDez(Data(pos:pos+15),16);
                    SD = Data(pos+16);
                    PS = Data(pos+17);
                    LFlag = Data(pos+18);
                    CCFlag = Data(pos+19);
                    
                    
                    if LFlag == 1                                                           
                        Sprache = LanguagesCodeTables(BintoDez(Data(pos+24:pos+31),8));
                    else
                        Sprache = 'No Language Def';
                    end
                    
                    IntCode = BintoDez(Data(pos+27+8*LFlag:pos+31+8*LFlag),5);
                
                    if darstellen == 1
                        disp([sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d S/D: %1d P/S: %1d CCFlag: %1d IntCode: %2d '...
                                          ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,SD,PS,CCFlag,IntCode) Sprache]);
                        darstellen = 0;
                    else
                        disp([sprintf('                                                               SId: %5d S/D: %1d P/S: %1d CCFlag: %1d IntCode: %2d '...
                                          ,SId,SD,PS,CCFlag,IntCode) Sprache]);
                    end
                    
                    pos = pos + 32 + 8*LFlag + 8 * CCFlag;
                end
                
 % ------------------------------------------------------------------------------------------------------------------------------
            case 18                                                                                            
                pos = 9;
                darstellen = 1;                                                             
                while pos<length(Data)
                    
                    SId = BintoDez(Data(pos:pos+15),16);
                    ASuFlags = BintoDez(Data(pos+16:pos+31),16);
                    NbrOfCluster = BintoDez(Data(pos+35:pos+39),5);
                    
                    pos = pos + 40;
                    
                    if NbrOfCluster == 0
                        if darstellen == 1
                            disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d ASuFlags: %5d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,ASuFlags));
                            darstellen = 0;
                        else
                            disp(sprintf('                                                               SId: %5d ASuFlags: %5d'...
                                              ,SId,ASuFlags));
                        end
                    end
                    
                    for g=1:NbrOfCluster
                        ClusterId = BintoDez(Data(pos:pos+7),8);
                        
                        if darstellen == 1
                            disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d SId: %5d ASuFlags: %5d ClusterId: %3d'...
                                              ,FrameNr,BlockNr,Type,Extension,CN,OE,PD,SId,ASuFlags,ClusterId));
                            darstellen = 0;
                        else
                            disp(sprintf('                                                               SId: %5d ASuFlags: %5d ClusterId: %3d'...
                                              ,SId,ASuFlags,ClusterId));
                        end
                        pos = pos + 8;
                    end
                    
                end
                
% ------------------------------------------------------------------------------------------------------------------------------                
            otherwise
                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d C/N: %1d OE: %1d P/D: %1d',FrameNr,BlockNr,Type,Extension,CN,OE,PD));
        end
% ------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------
    case 1
        OE=Data(5);
        Charset=BintoDez(Data(1:4),4);
        switch Extension
            case 0                                                                                               
                Label = char(BintoDez(Data(25:152),8));
                IdField = BintoDez(Data(9:24),16);
                disp([sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d OE: %1d Charset:%2d EId: %5d Ensemble Label: ',FrameNr,BlockNr,Type,Extension,OE,Charset,IdField) Label]);
% ------------------------------------------------------------------------------------------------------------------------------
            case 1                                                                                              
                Label = char(BintoDez(Data(25:152),8));
                IdField = BintoDez(Data(9:24),16);
                disp([sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d OE: %1d Charset:%2d SId: %5d Service Label: ',FrameNr,BlockNr,Type,Extension,OE,Charset,IdField) Label]);
            otherwise
                disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d OE: %1d Charset:%2d',FrameNr,BlockNr,Type,Extension,OE,Charset));
        end
        
% ------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------
    otherwise
        disp(sprintf('FrameNr: %2d FIB: %2d Type: %2d Extension: %2d',FrameNr,BlockNr,Type,Extension));
% ------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------
end























