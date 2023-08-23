% load mass balances for melting rate 40, 60 up to 200 and plot in for loop
% to see how the mass balance changes with melting rate

% load mass balance curve for melting rate 40
for i = 40:20:200
    if i<80
        load(['Results/budd_mr',num2str(i),'-20-Jun-2023/mass_balance_curve_struct.mat'])
    else
        load(['Results/budd_mr',num2str(i),'-21-Jun-2023/mass_balance_curve_struct.mat'])
    end
    time_ = mass_balance_curve_struct.time{1};
    plot(time_, mass_balance_curve_struct.mass_balance{1})
    hold on
end
xlabel('Time (years)')
ylabel('Mass balance (Gt/yr)')
legend('40','60','80','100','120','140','160','180','200')
