function pga_level_val = get_pga_level(obj)

obj.doTransmission(obj.MSG_GET_PGA_LEVEL);

pga_level_val = obj.m_pga_level_val;
