<#-- @formatter:off -->
<#include "mcitems.ftl">

package ${package}.item;

import net.fabricmc.fabric.api.client.itemgroup.FabricItemGroupBuilder;

public class ${name}Group {
    public static ItemGroup get(){
        return FabricItemGroupBuilder
        .create(new Identifier("${modid}","tab${registryname}"))
        .icon(()->{
          return new ItemStack(${mappedMCItemToItemStackCode(data.icon)});
        })
        .build();
    }
}

<#-- @formatter:on -->
