m_vec = logical(reshape(vial_masks_nicl2, [], 14));
t11 = FitResults.T1;
t11(t11 < 0) = NaN;
t11(t11 > 3) = NaN;

t1_vec = FitResults.T1(:);
t1_vec(t1_vec < 0) = NaN;
t1_vec(t1_vec > 3) = NaN;

vals = zeros(14,1);

for ii=1:14
   vals(ii) = mean(t1_vec(m_vec(:,ii)), 'omitnan'); 
end

figure; plot(vals, 'o', 'LineWidth', 2); xlabel('vial number'); ylabel('T1 [s]'); grid on;