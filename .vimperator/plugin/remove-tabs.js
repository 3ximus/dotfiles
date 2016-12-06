(function(){
    liberator.modules.commands.addUserCommand(['removeTabsLeft'], 'remove tabs left',
        function() {
            var ts = getBrowser().tabContainer.childNodes;
            var ct = getBrowser().selectedTab;
            var i;
            for( i=ts.length-1; ts[i]!=ct; i-- ) {}
            for( i--; i>=0; i-- ) {
                getBrowser().removeTab( ts[i] );
            }
        },{}
    );
    liberator.modules.commands.addUserCommand(['removeTabsRight'], 'remove tabs right',
        function(){
            var ts = getBrowser().tabContainer.childNodes;
            var ct = getBrowser().selectedTab;
            for( var i=ts.length-1; ts[i]!=ct; i-- ) {
                getBrowser().removeTab( ts[i] );
            }
        },{}
    );
})();
