function plotCost(Cost)

loglog(Cost.totalCost,'LineWidth',2);
hold on;
plot(Cost.fidelityNorm,'LineWidth',2,'Marker','.','MarkerSize',15)
legend('Total Cost','Fidelity Norm')

if Cost.temporalNorm(end)
    plot(Cost.temporalNorm,'kx-','LineWidth',2,'MarkerSize',5);
    lgd = get(gca,'Legend');
    lgd = lgd.String;
    legend([lgd(1:end-1),'Temporal Norm'])
end
if Cost.spatialNorm(end)
    plot(Cost.spatialNorm,'k.-','LineWidth',2,'MarkerSize',15);
    lgd = get(gca,'Legend');
    lgd = lgd.String;
    legend([lgd(1:end-1),'Spatial Norm'])
end
if isfield(Cost, 'l2Norm')
    if ~isempty(Cost.l2Norm)
        if Cost.l2Norm(end)
            plot(Cost.l2Norm,'.-','LineWidth',2,'MarkerSize',15);
            lgd = get(gca,'Legend');
            lgd = lgd.String;
            legend([lgd(1:end-1),'L2 Norm'])
        end
    end
end
xlabel 'Iteration Number'
ylabel 'Norm'
set(gca,'FontSize',16)
hold off