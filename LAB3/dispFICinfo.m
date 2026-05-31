function dispFICinfo(it,Rsym,K,DeintFFTtab)
   Data = zeros(1,(Rsym-1)*K*2);
    for f=1:Rsym-2
        Data(1+(f-1)*K*2:(f)*K*2) = [real(DeintFFTtab(f,:)) imag(DeintFFTtab(f,:))];
    end
    FIC = zeros(4, 2*K*3/4);
    for r=0:3
        FIC(r+1,:) = Data(r*2304+1:(r+1)*2304);
    end
    DataDep = [depuncturing(FIC(:,1:2016),16) depuncturing(FIC(:,2017:2292),15) depuncturing(FIC(:,2293:2304),8)];
    DataVit = zeros(4,768+6);
    for f=1:4
        DataVit(f,:) = DABViterbi(DataDep(f,:));
    end
    DataVit = DataVit(:,1:end-6);
    DataEne = zeros(size(DataVit));
    for m=1:4
        DataEne(m,:) = xor(DataVit(m,:),EnergyDispGen(768));
    end
    FIB=reshape(DataEne',256,12)';
    FIBCRCCheck = [CRC16(FIB(1,:)) CRC16(FIB(2,:)) CRC16(FIB(3,:)) CRC16(FIB(4,:)) ...
        CRC16(FIB(5,:)) CRC16(FIB(6,:)) CRC16(FIB(7,:)) CRC16(FIB(8,:)) ...
        CRC16(FIB(9,:)) CRC16(FIB(10,:)) CRC16(FIB(11,:)) CRC16(FIB(12,:))];
    if sum(FIBCRCCheck) ==12
        disp('CRC OK');
    else
        disp(['CRC Fail! Frame: ',num2str(it)]);
    end

    for FIBNr=1:12
        pos = 1;
        while pos < 241

            if FIB(FIBNr,pos:pos+7) == [1 1 1 1 1 1 1 1], break,end

            Type = BintoDez(FIB(FIBNr,pos:pos+2),3);
            FIGDataLength = BintoDez(FIB(FIBNr,pos+3:pos+7),5);

            FIGType(it,FIBNr,Type,FIGDataLength,FIB(FIBNr,pos+8:pos+8*(FIGDataLength+1)-1))

            pos = pos + (FIGDataLength+1)*8;
        end
    end

end
