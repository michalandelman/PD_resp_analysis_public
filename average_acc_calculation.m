function [average_acceleration,sum_acceleration] = average_acc_calculation(TimeSeries)

% Extract acceleration values from the three axes
accel_x = TimeSeries(1, :)./1000; % X-axis acceleration, milliG units
accel_y = TimeSeries(2, :)./1000; % Y-axis acceleration, milliG units
accel_z = TimeSeries(3, :)./1000; % Z-axis acceleration, milliG units

% Calculate magnitude of acceleration
accel_magnitude = sqrt(accel_x.^2 + accel_y.^2 + accel_z.^2);

% for locations:
% for i = 2:length(TimeSeries)-1
%     x_axis_accel = (accel_x(i+1)-2*accel_x(i)+accel_x(i-1))^2;
%     y_axis_accel = (accel_y(i+1)-2*accel_y(i)+accel_y(i-1))^2;
%     z_axis_accel = (accel_z(i+1)-2*accel_z(i)+accel_z(i-1))^2;
%     total_accel = sqrt(x_axis_accel+y_axis_accel+z_axis_accel);
%     acceleration(i) = total_accel/(0.1667^2); %6HZ sample
% end

% Calculate average acceleration
%average_acceleration = (sum(accel_magnitude))/(60*5); %Per second
% average_acceleration = mean(accel_magnitude);
average_acceleration = mean(accel_magnitude);
sum_acceleration = sum(accel_magnitude);
end