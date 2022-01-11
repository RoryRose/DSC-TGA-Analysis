function Te=f_createlineDSC(data,file,numfiles)
% Function to draw on two tangent lines to DSC curve and find the intersection
% of the two lines
%INPUTS:
%   fignum = figure index where the data is
%   roi = storage variable for the lines (#samples x 2 cell array)
%OUTPUTS:
%   roi = updated roi with new lines added
%   Te = extrapolated onset temperature of the transition
Te=NaN(1,numfiles);
for fignum=1:numfiles%length(file)
    figure(fignum)
    f_plotDSCres(data,file,fignum);
    for linenum=1:2
        figure(fignum);
        ax=gca;
        roi{fignum,linenum}=drawline(ax);
    end
    input('Happy to procede? Type any key to continue:','s');
    figure(fignum);
    [Te(fignum),y]=f_findintersectPoints(roi{fignum,1},roi{fignum,2});
    hold on
    scatter(Te(fignum),y)
    hold off
end