function error = fast_corner_error(img_0,img_1,img_2,img_3,patch_size,h)
[M,N] = size(img_0);
error = nan(M,N);
    for m = (1+patch_size):(M-patch_size)
        for n = (1+patch_size):(N-patch_size)
            idx_0 = [m,n];
            patch_0 = img_0((idx_0(1)-patch_size):(idx_0(1)+patch_size),(idx_0(2)-patch_size):(idx_0(2)+patch_size));
            idx_1 = [N+1-n,m];
            patch_1 = img_1((idx_1(1)-patch_size):(idx_1(1)+patch_size),(idx_1(2)-patch_size):(idx_1(2)+patch_size));
            idx_2 = [M+1-m,N+1-n];
            patch_2 = img_2((idx_2(1)-patch_size):(idx_2(1)+patch_size),(idx_2(2)-patch_size):(idx_2(2)+patch_size));
            idx_3 = [n,M+1-m];
            patch_3 = img_3((idx_3(1)-patch_size):(idx_3(1)+patch_size),(idx_3(2)-patch_size):(idx_3(2)+patch_size));
            err_01 = abs(patch_0-(1-patch_1));
            err_02 = abs(patch_0+(-patch_2));
            err_03 = abs(patch_0-(1-patch_3));
            err_12 = abs(patch_1-(1-patch_2));
            err_13 = abs(patch_1+(-patch_3));
            err_23 = abs(patch_2-(1-patch_3));
%             error(m,n) = sum(sum(h.*(err_01+err_02+err_03+err_12+err_13+err_23)));
            error(m,n) = sum(sum(h.*(err_01+err_02+err_03))) + sum(sum(h.*abs(err_01-err_03))) + sum(sum(h.*abs(err_02-err_13)));
%             error(m,n) = sum(sum(h.*abs(err_01-err_03))) + sum(sum(h.*abs(err_02-err_13)));
%             error
%             error(m,n) = sum(sum(h.*(abs(patch_0-(1-patch_1))+abs(patch_0-(1-patch_3))+abs(patch_0+(-patch_2)))));
        end
    end
end