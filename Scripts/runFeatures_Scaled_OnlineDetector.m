function runFeatures_Scaled_OnlineDetector(input, filename)
%metafile = fopen('input_data_attributes.txt','r+');
metafile = fopen(input,'r+');

wekaWrite = 0;
libsvmWrite = 1;

feature_min = [0.411 0.411 0.258 0.002 0.002 0.002 1.385 2 4.154 0.398 1049	0.076 0.02 155.773 -98.4 12	0.043 0.157];
feature_max = [3.838 3.7 3.599 5.101 4.464 4.464 22.188 40 887.518 2.154 21027.25 0.954	0.805 8587.724 167.6 300 2.083 1.114];

if (wekaWrite == 1)
    outfile = fopen(filename,'w');
    
    %populate metadata
    fprintf(outfile, '@relation target-classification\n\n');
    
    fprintf(outfile, '@attribute class {human, dog}\n');
    fprintf(outfile, '@attribute oldVel1 numeric \n');
    fprintf(outfile, '@attribute oldVel2 numeric \n');
    fprintf(outfile, '@attribute oldVel3 numeric \n');
    fprintf(outfile, '@attribute newVel1 numeric \n');
    fprintf(outfile, '@attribute newVel2 numeric \n');
    fprintf(outfile, '@attribute newVel3 numeric \n');
    fprintf(outfile, '@attribute dist numeric \n');
    fprintf(outfile, '@attribute time numeric \n');
    fprintf(outfile, '@attribute distTimeProd numeric \n');
    fprintf(outfile, '@attribute distTimeRatio numeric \n');
    fprintf(outfile, '@attribute fftfreq numeric \n');
    fprintf(outfile, '@attribute fftmoment numeric \n');
    fprintf(outfile, '@attribute percentFreq numeric \n');
    fprintf(outfile, '@attribute secMoment numeric \n');
    fprintf(outfile, '@attribute maxFreq numeric \n');
    fprintf(outfile, '@attribute freqWidth numeric \n');
    fprintf(outfile, '@attribute accRange numeric \n');
    fprintf(outfile, '@attribute veloMinMax numeric \n');
    fprintf(outfile, '@data \n');
    
end

if (libsvmWrite == 1)
    outfile2 = fopen(sprintf('svm_%s',filename),'w');
end

Line = textscan(metafile,'%d %s %d %d %d %s %d %d',1);

while (Line{1} > 0)
    %pause(0.1);
    filename = sprintf('Data/%s.data',char(Line{2}));
    fprintf('%d: \n',Line{1});
    Rate = Line{5};
    startTime = Line{3};
    stopTime = Line{4};
    
    if (startTime <= 3)
        startTime = 0;
    else
        startTime = startTime - 3;
    end
    stopTime = stopTime + 7;
    Type = char(Line{6});

    Comp = ReadComp(filename);
    len = length(Comp);
    if (len > stopTime*Rate)
        Data = Comp(startTime*Rate+1:stopTime*Rate);
    else
        Data = Comp(startTime*Rate+1:len);
    end

    FftWindow = Rate;
    FftOverlap = round(1/8*FftWindow);
    
    if (strcmp(Type,'dog') == 1 || strcmp(Type,'human') == 1)
        startBk = Line{7};
        stopBk = Line{8};
        BkData = Comp(startBk*Rate+1:stopBk*Rate);
    else
        BkData = [];
    end
        
    lambda = 3e8/5.8e9;
    Range = UnWrap(angle(Data)/2/pi, -0.5, 0.5)* lambda/2;
    
    winLen = 2*Rate;
    hit=zeros(1,length(Range));
    lastIndex = -7*Rate;
    hitActive = 0;
    
    startHit = -1;
    stopHit = -1;
    doneHit = 0;
    
    for j=1:length(Range)
        if (doneHit == 0)
            if (j-winLen + 1 <= 0)
                st = 1;
            else
                st = j-winLen + 1;
            end

            if((abs(max(Range(st:st+winLen-1)) - min(Range(st:st+winLen-1))) > 0.8))
                if (hitActive == 0)
                    startHit = j-winLen;
                    %stopHit = j;
                end
                hitActive = 1;
                lastIndex = j;
            end

            if (hitActive == 1)
                hit(j) = 1;
            end

            if (hitActive == 1 && (j - lastIndex > 6*Rate))
                hitActive = 0;
                stopHit = j - 6*Rate;
                doneHit = 1;
            end
        end
    end
    
    if (stopHit == -1)
        stopHit = j - 6*Rate;
    end
    
    %subplot(2,1,2);
    %plot(hit);
    %subplot(2,1,1);
    %plot(Range);
    %line([startHit startHit], [-1 1], 'Color','green');
    %line([stopHit stopHit], [-1 1], 'Color','red');
    
    % Calculate velocity based features
    VelWindow = 3;
    VelOverlap = 0.8; 
    
    if (startHit > 0)
     
        Data = Data(startHit:stopHit);
        fprintf(1, ' %4.2f', (stopHit-startHit) / Rate);
        [oldVel1 oldVel2 oldVel3] = SlidingPercentileVelocity(Data,VelWindow,VelOverlap,Rate);
        [newVel1 newVel2 newVel3] = ApproxMax(Data,VelWindow,VelOverlap,Rate);

        [dist time distTimeProd distTimeRatio] = DistTime(Data,Rate);

        %Calculate spectral features
        [fft_freq fft_moment] = AboveBgndFft(Data,BkData,FftWindow,FftOverlap,Rate);

        %calculate background
        if (length(BkData) > 0)
            [BackStats] = ComputeBack(BkData, FftWindow,FftOverlap);
        else
            [BackStats] = ComputeBack(Data, FftWindow,FftOverlap);
        end

        meanBack = BackStats(1:FftWindow);
        stdBack = BackStats(FftWindow+1:2*FftWindow);

        %calculate above background
        Img = AnomImage(Data, FftWindow, FftOverlap, Rate, meanBack, stdBack, 3);
        percentFreq = PropMeas(Img);

        Freq = FftFreq(double(FftWindow), double(Rate));
        secMoment = SecondMomentMeas(Img, Freq);

        maxFreq = MaxFreqMeas(Img, Freq,0.9,15);
        freqWidth = FreqWidthMeas(Img,4,7);

        accRange = AccRange(Data,0.5,0.8,Rate,0.9);
        veloVar = VeloVarMinMax(Data, 0.5, 0.8, Rate, 0.1,0.9);

        if (wekaWrite == 1)
            fprintf(outfile,'%s',Type);
            fprintf(outfile,',%5.3f',scaled(oldVel1,1));
            fprintf(outfile,',%5.3f',scaled(oldVel2,2));
            fprintf(outfile,',%5.3f',scaled(oldVel3,3));
            fprintf(outfile,',%5.3f',scaled(newVel1,4));
            fprintf(outfile,',%5.3f',scaled(newVel2,5));
            fprintf(outfile,',%5.3f',scaled(newVel3,6));
            fprintf(outfile,',%5.3f',scaled(dist,7));
            fprintf(outfile,',%5.3f',scaled(time,8));
            fprintf(outfile,',%5.3f',scaled(distTimeProd,9));
            fprintf(outfile,',%5.3f',scaled(distTimeRatio,10));
            fprintf(outfile,',%5.3f',scaled(fft_freq,11));
            fprintf(outfile,',%5.3f',scaled(fft_moment,12));
            fprintf(outfile,',%5.3f',scaled(percentFreq,13));
            fprintf(outfile,',%5.3f',scaled(secMoment,14));
            fprintf(outfile,',%5.3f',scaled(maxFreq,15));
            fprintf(outfile,',%5.3f',scaled(freqWidth,16));
            fprintf(outfile,',%5.3f',scaled(accRange,17));
            fprintf(outfile,',%5.3f',scaled(veloVar,18));
            fprintf(outfile,'\n');
        end

        if (libsvmWrite == 1)
            if(strcmp(Type,'dog') == 1)
                fprintf(outfile2,'1 ');
            else
                fprintf(outfile2,'2 ');
            end

            fprintf(outfile2,'1:%5.3f ',scaled(oldVel1,1));
            fprintf(outfile2,'2:%5.3f ',scaled(oldVel2,2));
            fprintf(outfile2,'3:%5.3f ',scaled(oldVel3,3));
            fprintf(outfile2,'4:%5.3f ',scaled(newVel1,4));
            fprintf(outfile2,'5:%5.3f ',scaled(newVel2,5));
            fprintf(outfile2,'6:%5.3f ',scaled(newVel3,6));
            fprintf(outfile2,'7:%5.3f ',scaled(dist,7));
            fprintf(outfile2,'8:%5.3f ',scaled(time,8));
            fprintf(outfile2,'9:%5.3f ',scaled(distTimeProd,9));
            fprintf(outfile2,'10:%5.3f ',scaled(distTimeRatio,10));
            fprintf(outfile2,'11:%5.3f ',scaled(fft_freq,11));
            fprintf(outfile2,'12:%5.3f ',scaled(fft_moment,12));
            fprintf(outfile2,'13:%5.3f ',scaled(percentFreq,13));
            fprintf(outfile2,'14:%5.3f ',scaled(secMoment,14));
            fprintf(outfile2,'15:%5.3f ',scaled(maxFreq,15));
            fprintf(outfile2,'16:%5.3f ',scaled(freqWidth,16));
            fprintf(outfile2,'17:%5.3f ',scaled(accRange,17));
            fprintf(outfile2,'18:%5.3f ',scaled(veloVar,18));
            fprintf(outfile2,'\n');
        end
    end
%    close all;
    Line = textscan(metafile,'%d %s %d %d %d %s %d %d',1);
end

fclose all;

function out = scaled(val, index)
    %out = val;
    out = (val-feature_min(index))/(feature_max(index)-feature_min(index));
    if (out > 1)
        out = 1;
    end

    if (out < 0)
        out = 0;
    end
    
end

end
