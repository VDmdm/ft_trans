function friend_invites_list_switch(sending) {
    if (sending)
    {
        document.getElementById('block-incoming').style.display = 'none';
        document.getElementById('block-sending').style.display = 'block';
        document.getElementById('switch-invites-btn-incoming').className = "";
        document.getElementById('switch-invites-btn-swnding').className = "btn-active";
    }
    else
    {
        document.getElementById('block-incoming').style.display = 'block';
        document.getElementById('block-sending').style.display = 'none';
        document.getElementById('switch-invites-btn-incoming').className = "btn-active";
        document.getElementById('switch-invites-btn-swnding').className = "";
    }
}