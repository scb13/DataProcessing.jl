function [trialdataT] = trialdata_reader_table(~)
if nargin < 1
    fullpath='C:\Users\scb47\Documents\MATLAB';
    cd(fullpath)
    monk=input('Choose animal: ','s');
    cd(monk)
    path=input('Input test folder: ','s'); %enter the data you want
    cd(path)
end

if ~isempty(dir('*.mat')) %if you've already pulled it
    cont=input('Already calculated, continue? 0==no, 1==yes: ');
    if ~cont
        load trialdataT.mat trialdataT
        cd ..\
        return
    else
        delete '*.mat'
    end
end

deal_with_sac(); %marks when saccades start and stop
files = dir; %whatever is directly in the path, make sure it is test trials, set above

framerate = 80; %from maestro and also file.key.d_framerate
frameinterval = 1000/framerate;

startTime=-ones(length(files)-2,1); %%%adjust for framerate
stopTime=startTime;   %%%adjust for framerate
tarDir=startTime;
tarSp=cell(length(files)-2,1); %%%adjust for framerate???
simptarSp=startTime;
contrast=startTime;
coherence=startTime;
Tfail=startTime;
Hpos=cell(length(files)-2,1);
Vpos=Hpos;
Hvel=Hpos;
Vvel=Hpos;
calcSp=Hpos;
condition=Hpos;
sacSta=Hpos;
sacSto=Hpos;
names=Hpos;
blink=zeros(size([Hpos,Hpos])); %%%adjust for framerate
err=[];

for i = 3:length(files) %first two 'files' are just dots, all others are actual
    file=readcxdata(files(i).name); %maestro function to read in saved trials, download from distribution

    if ~isempty(file.tagSections)
        %only really use tags to mark start, if multiple tags first marks
        %over all start
     %if  strcmp(file.tagSections(1).tag,'p_000') | strcmp(file.tagSections(1).tag,'start') %strcmp can handle variable string length
        start=file.tagSections(1).tStart;
     %else %if not notated
     %   start=file.trialInfo.segStart(3); %start of local motion
     %end
    else
        start=file.trialInfo.segStart(3); %start of local motion, often segment 3 (loose fix, tight fix, then start)
    end

    startTime(i-2,1) = framecorrect(start, frameinterval);
    stopTime(i-2,1) = framecorrect(file.trialInfo.segStart(end), frameinterval);

Hpos{i-2,:}=file.data(1,:)*.025 - mean(file.data(1,start-150:start)*.025);
Vpos{i-2,:}=file.data(2,:)*.025 - mean(file.data(2,start-150:start)*.025);
Hvel{i-2,:}=file.data(3,:)*.09189 - mean(file.data(3,start-150:start)*.09189);
Vvel{i-2,:}=file.data(4,:)*.09189 - mean(file.data(4,start-150:start)*.09189);

%limit speed to axis of stimiulus in beggining before correctly assuming
%eye is moving in target axis (otherwise trial would fail)
%calcSp{i-2,:}=sqrt(Vvel{i-2,:}.^2+Hvel{i-2,:}.^2); %  calculates speed magnitude of eye

    ddex=strfind(file.trialname,'d'); %target direction and speed from trial name
    tarDir(i-2,1)=str2double(file.trialname(ddex+1:ddex+3));
    if isnan(tarDir(i-2,1))
        hp = file.targets.hpos(2,end);
        vp = file.targets.vpos(2,end);
        if hp>0 && vp==0
            tarDir(i-2,1) = 0;
        elseif hp>0 && vp>0
            tarDir(i-2,1) = 45;
        elseif hp==0 && vp>0
            tarDir(i-2,1) = 90;
        elseif hp<0 && vp>0
            tarDir(i-2,1) = 135;
        elseif hp<0 && vp==0
            tarDir(i-2,1) = 180;
        elseif hp<0 && vp<0
            tarDir(i-2,1) = 225;
        elseif hp==0 && vp<0
            tarDir(i-2,1) = 270;
        elseif hp>0 && vp<0
            tarDir(i-2,1) = 315;
        end
    end
    d2r = tarDir(i-2,1)/180*pi; %degrees to radians
    calcSp{i-2,:} = Hvel{i-2,:}*cos(d2r) + Vvel{i-2,:}*sin(d2r); %rotate axis to target and only take x
%{
    figure; hold on %compare speed options to double check
plot(sqrt(Vvel{i-2,:}.^2+Hvel{i-2,:}.^2))
plot(calcSp{i-2,:})
ylim([0,11])
 %}
    if ~bitget(file.key.flags,3) == 1  %failed trial == 1
         Tfail(i-2,1) = 1;
    else
         Tfail(i-2,1) = 0;
    end

    sdex=strfind(file.trialname,'s');
    %
    tarSp{i-2} = zeros(size(calcSp{i-2}));
    hvtemp = zeros(size(calcSp{i-2}));
    vvtemp = zeros(size(calcSp{i-2}));
    if Tfail(i-2,1)==1
        for ii = 1:length(file.targets.on)
            hvtemp(file.targets.on{ii}(1)+1:end) = file.targets.hvel(ii,file.targets.on{ii}(1)+1:end);
            vvtemp(file.targets.on{ii}(1)+1:end) = file.targets.vvel(ii,file.targets.on{ii}(1)+1:end);
            %tarSp{i-2} = speedcorrect(sqrt(vvtemp.^2 + hvtemp.^2),frameinterval,startTime(i-2,1));
        end
    else
        for ii = 1:length(file.targets.on)
            %if seg0 dropped will need to use tRecordOn file target
            %parameter
            hvtemp(file.targets.on{ii}(1)+1:file.targets.on{ii}(2)) = file.targets.hvel(ii,file.targets.on{ii}(1)+1:file.targets.on{ii}(2));
            vvtemp(file.targets.on{ii}(1)+1:file.targets.on{ii}(2)) = file.targets.vvel(ii,file.targets.on{ii}(1)+1:file.targets.on{ii}(2));
            %
        end
    end
    tarSp{i-2} = speedcorrect(sqrt(vvtemp.^2 + hvtemp.^2),frameinterval,startTime(i-2,1));
    %
    if file.trialname(sdex+1)=='p'
        simptarSp(i-2,1)=str2double(file.trialname(sdex+2:end));
    else
        simptarSp(i-2,1)=str2double(file.trialname(sdex+1:end));
    end
    if isnan(simptarSp(i-2,1)) %if something else at end
        simptarSp(i-2,1)=str2double(file.trialname(sdex+2:sdex+3));
    end
    if isnan(simptarSp(i-2,1)) %if 1 digit speed
        simptarSp(i-2,1)=str2double(file.trialname(sdex+2:sdex+2));
    end
    %}
    %contrast and coherence from trial name
    if strfind(file.trialname,'c')
        cdex=strfind(file.trialname,'c');
        contrast(i-2,1)=str2double(file.trialname(cdex+1:cdex+3));
    else
        contrast(i-2,1)=100;
    end
    if strfind(file.trialname,'h')
        hdex=strfind(file.trialname,'h');
        if file.trialname(hdex-1)=='_'
            coherence(i-2,1)=str2double(file.trialname(hdex+1:hdex+3));
        else
            coherence(i-2,1)=100;
        end
    else
        coherence(i-2,1)=100;
    end

    if file.mark1  %checks if there are saccades
    sacSta{i-2,:}=file.mark1(1,:);
    sacSto{i-2,:}=file.mark2(1,:);
    else
        sacSta{i-2,:}=NaN;
        sacSto{i-2,:}=NaN;
    end

    stp=find(file.trialname=='_');
    if ~isempty(stp)
    chck=isstrprop(file.trialname,'upper') | stp(1)>2; %get condition from file name
    if chck(1)
        condition{i-2,1}=file.trialname(1:stp(1)-1);
    else
        condition{i-2,1}='c';
    end
    else
    condition{i-2,1}='c';
    end

    names{i-2,1}=file.trialname;

    %get blink length and start if blink, from 6/22/18 on as requires tags
    %in maestro
    if ~isempty(find(file.trialname=='B', 1)) || ~isempty(find(file.trialname=='+',1)) || ~isempty(find(file.trialname=='-',1))
        try
            if  strcmp(file.tagSections(end).tag, 'blink') || strcmp(file.tagSections(end).tag, 'Blink')
                tStart=file.tagSections(end).tStart-start;
                tLen= file.tagSections(end).tLen;
                blink(i-2,:)=[framecorrect(tStart,frameinterval) framecorrect(tLen,frameinterval)];
            end
        catch
            err=[err,i-2];
        end
    end
end

if ~isempty(err)
fprintf('Error in Maestro tag for trial %d, no blink recorded \n',err) %if blink start and length failed for any reason
end

simptarSp=floor(simptarSp); %%% %required in order to use trial speeds as field names, think of something better and don't forget original speeds...

if isnan(tarDir) %fill with -1 if direction not specified per trial
    tarDir(:)=-1;
end
if isnan(simptarSp) %fill with -1 if speed not specified per trial
    simptarSp(:)=10;
end

%file reader part 2, more accurate saccade useability calculation, less
%false positives, recovers useability and assigns to trialdata

trialdataP2=struct();
useablei=struct();
for s=1:length(unique(simptarSp))
    speed=unique(simptarSp);
    txt=sprintf('sp%d',speed(s));
    trialdataP2.(txt).order=[];trialdataP2.(txt).onset=[];trialdataP2.(txt).useablei=[];
end
figure
%sets up open loop
for i = 1:length(startTime)
    txt=sprintf('sp%d',simptarSp(i));
    trialdataP2.(txt).order=[trialdataP2.(txt).order;i];
    %HvelPos=Hvel{i,:};
    %VvelPos=Vvel{i,:};
    %temp=sqrt(VvelPos.^2+HvelPos.^2);
    temp=calcSp{i,:};
    if length(temp)<startTime(i)+200
        continue
    end
    if sum(startTime(i)<sacSta{i} & sacSta{i}<startTime(i)+200)>0 %saccade in open loop
        subplot(1,2,1); hold on
        plot(1:201,temp(startTime(i):startTime(i)+200))
    else
        subplot(1,2,2); hold on
        plot(1:201,temp(startTime(i):startTime(i)+200))
        useablei.(txt)(find(trialdataP2.(txt).order==i))=1;
    end
    trialdataP2.(txt).onset=[trialdataP2.(txt).onset; temp(startTime(i):startTime(i)+200)];%onset
end


%if saccade happens during open loop, whole trial removed from pool
%%%%seperate by more than just speed?
if input('Check Saccades Manually? 0==no, 1==yes: ')
    for s=1:length(unique(simptarSp))
        speed=unique(simptarSp);
        txt=sprintf('sp%d',speed(s));
        figure %to initialize removeing saccades
        trialdataP2.(txt).useablei=removeSaccadeTrPerturb(trialdataP2.(txt).onset); %semimanual
        length(trialdataP2.(txt).useablei)
        trialdataP2.(txt).useablei;
    end
else
    for s=1:length(unique(simptarSp))
        speed=unique(simptarSp);
        txt=sprintf('sp%d',speed(s));
        trialdataP2.(txt).useablei = find(useablei.(txt));
        length(trialdataP2.(txt).useablei)
        trialdataP2.(txt).useablei;
    end
end

useable=zeros(length(files)-2,1);
for s=1:length(unique(simptarSp))
    speed=unique(simptarSp);
    txt=sprintf('sp%d',speed(s));
    for i=1:length(trialdataP2.(txt).useablei)
        useable(trialdataP2.(txt).order(trialdataP2.(txt).useablei(i)),1)=1; %take the useable index and get the ordered index at that spot to assign useability
    end
end
useable(Tfail==1)=0;
sum(useable)

trialdataT=table(condition,names,coherence,contrast,tarDir,tarSp,startTime,stopTime,Hpos,Vpos,Hvel,Vvel,calcSp,sacSta,sacSto,useable,blink);
save('trialdataT','trialdataT');
cd ..\

%if spike data and if binary file already exists, process with other
%sorting stuff then add back in seperatly
