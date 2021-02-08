function room_list_switch(allrooms) {
    if (allrooms)
    {
        document.getElementById('block-myrooms').style.display = 'none';
        document.getElementById('block-allrooms').style.display = 'block';
        document.getElementById('switch-btn-myrooms').className = "";
        document.getElementById('switch-btn-allrooms').className = "btn-active";
    }
    else
    {
        document.getElementById('block-myrooms').style.display = 'block';
        document.getElementById('block-allrooms').style.display = 'none';
        document.getElementById('switch-btn-myrooms').className = "btn-active";
        document.getElementById('switch-btn-allrooms').className = "";
    }
}