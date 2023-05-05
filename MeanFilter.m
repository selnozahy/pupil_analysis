function [FilteredArray] = MeanFilter(Array,WindowSize,IsNaN)

if(size(Array,2)>size(Array,1))
    ExpandedArray=[fliplr(Array),Array,fliplr(Array)];
else
    ExpandedArray=[fliplr(Array'),Array',fliplr(Array')]';
end

ArrayLength=max(size(Array));
FilteredArray=zeros(size(Array));

if(IsNaN==1)
    for(i=(ArrayLength+1):(2*ArrayLength))    
       FilteredArray(i-ArrayLength)=nanmean(ExpandedArray((i-floor(WindowSize/2)):(i+floor(WindowSize/2))));
    end
else
    FilteredArray=conv(ExpandedArray,ones(WindowSize,1)/WindowSize,'same');
    FilteredArray=FilteredArray((ArrayLength+1):(2*ArrayLength));
end