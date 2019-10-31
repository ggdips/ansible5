all:
    children:
        ${ans_inv_name}:
            hosts:
%{ for host in ans_inv_hosts ~}
                ${host}:
%{ endfor ~}
            vars:
                ansible_user: ${ans_extra_user}
                ansible_ssh_private_key_file: ${ans_extra_key}
                nginx_worker_connections: ${ans_extra_wc}
                nginx_client_max_body_size: ${ans_extra_cmbs}
                nginx_locations: ${ans_extra_locs}
                nginx_vhosts: ${ans_extra_vhosts}
