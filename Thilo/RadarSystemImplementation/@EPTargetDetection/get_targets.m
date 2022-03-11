function targets = get_targets(obj)

obj.doTransmission(obj.MSG_GET_TARGETS);

targets = obj.m_targets;
