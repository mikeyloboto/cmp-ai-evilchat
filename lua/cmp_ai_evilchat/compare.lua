return function(entry1, entry2)
  if entry1.source.name == 'cmp_ai_evilchat' and entry2.source.name == 'cmp_ai_evilchat' then
    return (#entry1.completion_item.label > #entry2.completion_item.label)
  end
  if entry1.source.name == 'cmp_ai_evilchat' and entry2.source.name ~= 'cmp_ai_evilchat' then
    return true
  elseif entry1.source.name ~= 'cmp_ai_evilchat' and entry2.source.name == 'cmp_ai_evilchat' then
    return false
  else
    return nil
  end
end
