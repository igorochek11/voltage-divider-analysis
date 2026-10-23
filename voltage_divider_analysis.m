% DC voltage divider - six tests.
clear; clc;

% 1. Recorded values. Resistance is in ohms; voltage is in volts.
Experiment = (1:6)';
Vin_V = [4.98; 4.98; 4.98; 4.98; 4.98; 4.98];
R1_nom_Ohm = [10000; 10000; 10000; 1000; 1000; 1000];
R2_nom_Ohm = [1000; 2000; 10000; 5000; 10000; 20000];
Vout_meas_V = [0.45; 0.829; 2.489; 4.15; 4.53; 4.74];

% Readings for the two 10k parts and the two 1k parts.
R10_A = 9830; R10_B = 9890;
R1_A = 979;   R1_B = 980;

% R1 is the upper resistor. R2 is the lower resistor.
R1_meas_Ohm = [R10_A; R10_A; R10_A; R1_A; R1_A; R1_A];
R2_meas_Ohm = [R1_A;
              R1_A + R1_B;
              R10_B;
              R10_A * R10_B / (R10_A + R10_B);
              R10_A;
              R10_A + R10_B];

% 2. Calculate voltage, percentage difference and current.
Vout_nom_V = Vin_V .* R2_nom_Ohm ./ (R1_nom_Ohm + R2_nom_Ohm);
Vout_actual_V = Vin_V .* R2_meas_Ohm ./ (R1_meas_Ohm + R2_meas_Ohm);
Error_nom_pct = 100 * abs(Vout_meas_V - Vout_nom_V) ./ Vout_nom_V;
Error_actual_pct = 100 * abs(Vout_meas_V - Vout_actual_V) ./ Vout_actual_V;
I_calc_mA = 1000 * Vin_V ./ (R1_meas_Ohm + R2_meas_Ohm);

% Save the results.
results = table(Experiment, Vin_V, R1_nom_Ohm, R2_nom_Ohm, ...
    R1_meas_Ohm, R2_meas_Ohm, Vout_meas_V, Vout_nom_V, ...
    Vout_actual_V, Error_nom_pct, Error_actual_pct, I_calc_mA);
disp(results);
writetable(results, 'voltage_divider_results.csv');

% 3. Draw the voltage graph.
fig_voltage = figure(1);
clf(fig_voltage);
plot(Experiment, Vout_meas_V, 'o-', ...
     Experiment, Vout_nom_V, 's--', ...
     Experiment, Vout_actual_V, '^:');
grid on;
xlabel('Experiment number');
ylabel('Output voltage (V)');
title('Voltage divider: measured vs calculated');
legend('Measured', 'Nominal resistors', 'Measured resistors', ...
    'Location', 'best');
xticks(1:6);

% Draw the difference graph.
fig_error = figure(2);
clf(fig_error);
bar(Experiment, [Error_nom_pct Error_actual_pct]);
grid on;
xlabel('Experiment number');
ylabel('Absolute relative error (%)');
title('Voltage divider: relative error');
legend('Nominal resistors', 'Measured resistors', 'Location', 'best');
xticks(1:6);

% Save the graphs.
exportgraphics(fig_voltage, 'voltage_comparison.png', 'Resolution', 300);
exportgraphics(fig_error, 'relative_error.png', 'Resolution', 300);

% 4. Meter check. Use the MM420 manual limits.
% Voltage: 0.5% of the reading + 5 display steps.
% Resistance: 1.2% of the reading + 5 display steps.
% Assumed voltage ranges: input 40V; outputs 1-3 4V, outputs 4-6 40V.
% Assumed resistance ranges: 1k parts 4k; 10k parts 40k.
% The manual assumes 18-28 C and calibration within one year.
% These conditions and some meter ranges were not recorded.
% Source: Klein MM420 Instructions, English pages 2-3.
% https://data.kleintools.com/sites/all/product_assets/documents/instructions/klein/MM420%20Instructions_web.pdf
Vin_limit_V = 0.005 .* Vin_V + 5 * 0.01;
Assumed_Vout_range_V = [4; 4; 4; 40; 40; 40];
Vout_resolution_V = [0.001; 0.001; 0.001; 0.01; 0.01; 0.01];
Vout_meter_limit_V = 0.005 .* Vout_meas_V + 5 .* Vout_resolution_V;

% Leave extra room for rounding in the shorter 0.45V record.
Vout_recording_allowance_V = [0.005; 0; 0; 0; 0; 0];
Vout_interval_low_V = Vout_meas_V - Vout_meter_limit_V ...
    - Vout_recording_allowance_V;
Vout_interval_high_V = Vout_meas_V + Vout_meter_limit_V ...
    + Vout_recording_allowance_V;

% Part order: 10k-A, 10k-B, 1k-A, 1k-B.
R_read_Ohm = [R10_A; R10_B; R1_A; R1_B];
R_resolution_Ohm = [10; 10; 1; 1];
R_meter_limit_Ohm = 0.012 .* R_read_Ohm + 5 .* R_resolution_Ohm;
% Leave extra room for rounding in the shorter 0.98k record.
R_recording_allowance_Ohm = [0; 0; 0; 5];
R_low = R_read_Ohm - R_meter_limit_Ohm - R_recording_allowance_Ohm;
R_high = R_read_Ohm + R_meter_limit_Ohm + R_recording_allowance_Ohm;
assert(all(R_low > 0));

% Build the smallest and largest resistor values.
R1_low = [R_low(1); R_low(1); R_low(1); R_low(3); R_low(3); R_low(3)];
R1_high = [R_high(1); R_high(1); R_high(1); R_high(3); R_high(3); R_high(3)];
R2_low = [R_low(3); R_low(3)+R_low(4); R_low(2); ...
    R_low(1)*R_low(2)/(R_low(1)+R_low(2)); R_low(1); R_low(1)+R_low(2)];
R2_high = [R_high(3); R_high(3)+R_high(4); R_high(2); ...
    R_high(1)*R_high(2)/(R_high(1)+R_high(2)); R_high(1); R_high(1)+R_high(2)];

% Find the lowest and highest calculated output voltage.
Vpred_low_V = (Vin_V - Vin_limit_V) .* R2_low ./ (R1_high + R2_low);
Vpred_high_V = (Vin_V + Vin_limit_V) .* R2_high ./ (R1_low + R2_high);
% Check whether the measured and calculated voltage ranges share values.
Intervals_overlap = Vout_interval_low_V <= Vpred_high_V ...
    & Vout_interval_high_V >= Vpred_low_V;
Residual_measuredR_V = abs(Vout_meas_V - Vout_actual_V);

% The meter also draws a small current. Estimate its effect using 10 megohms.
R2_loaded_Ohm = R2_meas_Ohm .* 1e7 ./ (R2_meas_Ohm + 1e7);
Vout_loaded_10M_V = Vin_V .* R2_loaded_Ohm ./ (R1_meas_Ohm + R2_loaded_Ohm);
Loading_shift_V = Vout_actual_V - Vout_loaded_10M_V;

% Save the meter check. Overlapping ranges do not prove perfect accuracy.
accuracy = table(Experiment, Assumed_Vout_range_V, Vout_resolution_V, ...
    Vout_meter_limit_V, Vout_recording_allowance_V, ...
    Vout_interval_low_V, Vout_interval_high_V, Vpred_low_V, Vpred_high_V, ...
    Intervals_overlap, Residual_measuredR_V, Vout_loaded_10M_V, Loading_shift_V);
disp(accuracy);
writetable(accuracy, 'voltage_divider_accuracy.csv');
fprintf('Conditional interval overlap: %d of %d tests.\n', ...
    sum(Intervals_overlap), numel(Experiment));
