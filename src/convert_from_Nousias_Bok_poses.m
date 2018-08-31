function calib_params = convert_from_Nousias_Bok_poses(data_dir)
    ext_files = dir([data_dir, '/Ext*']);
    s = 0;
    for t = 1:length(ext_files)
        s = s+1;
        load([data_dir,'/',ext_files(s).name],'ExtParamLF');
        poses(:,:,s) = ExtParamLF;
    end
    figure; hold on;
    for t = 1:length(ext_files)
%         rot = expm(skew3([0,0,pi/2]))*expm(skew3([pi,0,0]))*poses(1:3,1:3,t)';
%         rot = expm(skew3([pi,0,0]))*poses(1:3,1:3,t)';
        rot = poses(1:3,1:3,t);
%         pos = rot*(-poses(1:3,4,t));
        pos = poses(1:3,4,t);
        plotarray3([pos';pos'+50*rot(:,1)';],'r');
        plotarray3([pos';pos'+50*rot(:,2)';],'g');
        plotarray3([pos';pos'+50*rot(:,3)';],'b');
        skew = logm(rot);
        ang = [skew(3,2),skew(1,3),skew(2,1)];
        calib_ext(2*t-1,:) = pos';
        calib_ext(2*t,:) = ang;
    end
    int_files = dir([data_dir, '/Int*']);
    load([data_dir,'/',int_files(1).name],'IntParamLF');
    lenslet_radius = 5;
    K1 = IntParamLF(1)*lenslet_radius;
    K2 = IntParamLF(2)*lenslet_radius;
    fx = IntParamLF(3);
    fy = IntParamLF(4);
    cx = IntParamLF(5);
    cy = IntParamLF(6);
    k1 = IntParamLF(7);
    k2 = IntParamLF(8);
    calib_int = [K1,K2,fy;cy,cx,fx;k1,k2,0;0,0,0];
    calib_params = [calib_int;calib_ext];
end
