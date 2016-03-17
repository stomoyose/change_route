class Change_route < Controller

	def switch_ready (datapath_id)
	@host1_ip = Pio::IPv4Address.new("192.168.1.1")
	@host1_mac = Pio::Mac.new("54:ee:75:70:ff:d7")
	@host2_ip = Pio::IPv4Address.new("192.168.1.2")
	@host2_mac = Pio::Mac.new("54:ee:75:70:58:bc")
	@broadcast_mac = Pio::Mac.new("ff:ff:ff:ff:ff:ff")
	@to_cg = Pio::IPv4Address.new("172.16.1.2")
	@to_sd = Pio::IPv4Address.new("172.16.1.1")	
	@test1_ip = Pio::IPv4Address.new("192.168.1.51")
	@test1_mac = Pio::Mac.new("54:ee:75:11:11:51")
	@test2_ip = Pio::IPv4Address.new("192.168.1.52")
	@test2_mac = Pio::Mac.new("54:ee:75:11:11:52")

		info "Switch #{ datapath_id.to_hex } is UP"
		if datapath_id == 2
			 send_flow_mod_add(
				datapath_id,
				:match => Match.new(:nw_dst => @to_cg)  ,
				:actions => ActionOutput.new( OFPP_CONTROLLER )
				)
			 send_flow_mod_add(
				datapath_id,
				:match => Match.new(:nw_dst => @to_sd) ,
				:actions => ActionOutput.new( OFPP_CONTROLLER )
				)				
			send_flow_mod_add(
				datapath_id,
				:match => Match.new(:dl_dst => @host1_mac),
				:actions => ActionOutput.new( :port => 2 )
				)
			send_flow_mod_add(
				datapath_id,
				:match => Match.new(:dl_dst => @host2_mac ),
				:actions => ActionOutput.new( :port => 1 )
				)
			send_flow_mod_add(
				datapath_id,
				:match => Match.new(:dl_dst => @broadcast_mac ),
				:actions => ActionOutput.new( OFPP_FLOOD )
				)
			send_flow_mod_add(
				datapath_id,  #dpid=2
				:match => Match.new(:nw_dst => @test2_ip) ,
				:actions => [ActionSetNwDst.new("192.168.1.52"),\
							ActionSetDlDst.new("54:ee:75:11:11:52"),\
							ActionOutput.new( :port => 4 )]
				)
			end
		end
	
	
	def packet_in datapath_id, message
		p message.ipv4_daddr
			if datapath_id == 2
			#change to crossgate 
				if message.ipv4_daddr == @to_cg
				p "change to CrossGate" 
				send_flow_mod_delete(
				datapath_id,  #dpid=2
				:match => Match.new(:nw_dst => @test2_ip) 
				)
				send_flow_mod_add(
				datapath_id,  #dpid=2
				:match => Match.new(:nw_dst => @test1_ip) ,
				:actions => [ ActionSetNwDst.new("192.168.1.52"),ActionSetDlDst.new("54:ee:75:11:11:52"),ActionOutput.new(:port => 3) ]
				)
				end
			#change to shiodome
				if message.ipv4_daddr == @to_sd
				p "change to Shiodome"
				send_flow_mod_delete(
				datapath_id,  #dpid=2
				:match => Match.new(:nw_dst => @test1_ip) 
				)
				send_flow_mod_add(
				datapath_id,  #dpid=2
				:match => Match.new(:nw_dst => @test2_ip) ,
				:actions => [ActionSetNwDst.new("192.168.1.52"),\
							ActionSetDlDst.new("54:ee:75:11:11:52"),\
							ActionOutput.new( :port => 4 )]
				)
				end
			end
	end
end
