
figure();

subplot(2,1,1);
loglog(input, error, 'LineStyle', '-', 'Marker','square', 'Linewidth', 2, 'MarkerSize', 1);
ylabel('error')
xlabel('input')

subplot(2,1,2);
loglog(input, time, 'LineStyle', '-', 'Marker','square', 'Linewidth', 2, 'MarkerSize', 1);
ylabel('time')
xlabel('input')
