% This code must be run using MATLAB

while(1)
    
    ArrivalData_url = 'https://inlinesensor.firebaseio.com/arrival/.json';
    TimeData_url = 'https://inlinesensor.firebaseio.com/duration/.json';

    isDataAvailable = false; % flag variable
    cutoff = 1; % keeps track of where actual data ends
    %predictionVal = 900;

    xData = webread(ArrivalData_url);
    xData(1,:) = [];
    x = str2double(xData);

    yData = webread(TimeData_url);
    yData(1,:) = [];
    y = str2double(yData);

    matSize = size(x,1);

    for c = 1:matSize
        if (x(c) == 0)
            cutoff = c;
            break;
        end
    end

    for c = 0:(matSize-cutoff)
        if (cutoff == 1)
            break;
        end;
        x(cutoff,:) = [];
        y(cutoff,:) = [];
    end

    if (cutoff > 2) % extrapolation requires atleast 4 points
        plot(x, y)
        title('Time in Line vs. Arrival Time', 'fontsize', 20);
        xlabel('Arrival Time (seconds)', 'fontsize', 15);
        xlim([min(x), max(x)]);
        ylabel('Time in Line (seconds)', 'fontsize', 15);
        ylim([min(y) - 0.1 * min(y), max(y) + 0.1 * max(y)]);

        isDataAvailable = true;
    end
    
    if (isDataAvailable)
        %avgTime = mean(x)
        %predictionVal = interp1(x, y, max(x) + 60, 'linear', 'extrap')
        x = x-min(x);
%         degrees = size(x,1) - 1;
%         fittingFunc = polyfit(x,y,degrees);
%         predictionVal = 0;
%         for c = 0:degrees
%             predictionVal = predictionVal + (fittingFunc(c+1))*(5+(max(x))^(degrees-c));
%         end
        sizeVal = size(x,1);
        linReg = polyfit([x(sizeVal), x(sizeVal-1)], [y(sizeVal), y(sizeVal-1)], 1);

        predictionVal = linReg(1)*(2*x(sizeVal)-x(sizeVal-1))+linReg(2);
 
        if (predictionVal <= 1 || (abs(predictionVal - median(y))) > (var(y))^(1/2))
            predictionVal = median(y);
        end
    else
        predictionVal = 900;
    end
    
    predictionVal
    keyValue = strcat('{"CurrentPrediction": ', num2str(predictionVal), '}');
    prediction_url = 'https://inline-c2e5b.firebaseio.com/prediction/.json';
    options = weboptions("RequestMethod", "put");
    response = webwrite(prediction_url, keyValue, options);
    fprintf("Waiting for 10 seconds\n");
    pause(3);
end
