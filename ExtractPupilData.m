function[area,centre]=ExtractPupilData(PupilFileName)

    if(iscell(PupilFileName))
        PupilTable=[];
        for(i=1:length(PupilFileName))
            PupilTable=[PupilTable;csvread(PupilFileName{i},3,0)];
        end
    else
        PupilTable=csvread(PupilFileName,3,1);
    end
    ConfidenceThreshold=0.95;
%     RemoveArray=(double(min(PupilTable(:,[4:3:4+3*12]),[],2)>ConfidenceThreshold))./(min(PupilTable(:,[4:3:4+3*12]),[],2)>ConfidenceThreshold);
    RemoveArray=(double((PupilTable(:,[4:3:4+3*12]))>ConfidenceThreshold))./((PupilTable(:,[4:3:4+3*12]))>ConfidenceThreshold);
%     RemoveArray(1==[0;max((abs(diff(PupilTable(:,[2:3:2+3*12])))>20),[],2)])=NaN;
    RemoveArray(1==[zeros(1,13);(abs(diff(PupilTable(:,[2:3:2+3*12])))>20)])=NaN;

    area=zeros(length(RemoveArray),1);
    centre=zeros(length(RemoveArray),2);
%     RemoveArray=MeanFilter(RemoveArray,3,0);
    for(i=1:13)
       RemoveArray(:,i)=MeanFilter(RemoveArray(:,i),3,0);
    end
    for(i=1:13)

    end
    
    
    for(i=1:length(RemoveArray))
%         ellipse_t = fit_ellipse(PupilTable(i,[2:3:2+3*11]),PupilTable(i,[3:3:3+3*11]));
        x=PupilTable(i,[2:3:2+3*11]).*RemoveArray(i,1:12);
        y=PupilTable(i,[3:3:3+3*11]).*RemoveArray(i,1:12);
        x_med=nanmedian(PupilTable(i,[2:3:2+3*12]).*RemoveArray(i,1:13));
        y_med=nanmedian(PupilTable(i,[3:3:3+3*12]).*RemoveArray(i,1:13));
        
        for(j=1:12)
           if(abs(x(j)-x_med)>2*nanmedian(abs(x-x_med)))
               x(j)=NaN;
               y(j)=NaN;
           end
          if(abs(y(j)-y_med)>2*nanmedian(abs(y-y_med)))
               x(j)=NaN;
               y(j)=NaN;
          end
        end
           
        x=x(~isnan(x));
        y=y(~isnan(y));
        if(length(x)>8) 
            ellipse_t = fit_ellipse(x,y);
            if(isempty(ellipse_t))
                area(i)=NaN;
                centre(i,:)=[NaN,NaN]; 
            elseif(isempty(pi*ellipse_t.a*ellipse_t.b))
                area(i)=NaN;
                centre(i,:)=[NaN,NaN]; 
            else
    %             area(i)=pi*ellipse_t.a*ellipse_t.b*RemoveArray(i);
    %             centre(i,:)=[ellipse_t.X0_in,ellipse_t.Y0_in]*RemoveArray(i);
                area(i)=pi*ellipse_t.a*ellipse_t.b;
                centre(i,:)=[ellipse_t.X0_in,ellipse_t.Y0_in];
            end
        else
            area(i)=NaN;
            centre(i,:)=[NaN,NaN]; 
        end
    end
    x=area>2*prctile(area,95);
    x=MeanFilter(x,3,0)>0;
    area(x)=NaN;
    centre(x,:)=NaN;
