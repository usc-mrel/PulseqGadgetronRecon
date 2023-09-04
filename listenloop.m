port_list   = [  18000,   18001,   18002,    18003];
handle_list = {@t1_vfa, @t2_map, @b1_map, @t1_irse};

parfor p_i = 1:length(port_list)
    while true
        gadgetron.external.listen(port_list(p_i), handle_list{p_i})
    end
end
