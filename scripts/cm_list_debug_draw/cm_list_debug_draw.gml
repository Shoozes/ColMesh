function cm_list_debug_draw(list, tex = -1, color = c_teal, mask = 0)
{
	for (var i = CM_LIST.NUM; i < list[CM_LIST.SIZE]; ++i)
	{
		cm_debug_draw(list[i++], tex, color, mask);
	}
}