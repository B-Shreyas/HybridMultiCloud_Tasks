<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <title></title>
    <style type="text/css">
      body{
  margin: 0;
  padding: 0;
  font-family: "montserrat",sans-serif;
  background: #000000;
}

.middle{
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%,-50%);
}

.text{
  color: #f2ee0f;
  text-transform: uppercase;
  text-decoration: underline overline dotted red;
  font-size: 70px;
  text-align: center;
  letter-spacing: 14px;
}

.text::before,.text::after{
  content: attr(data-text);
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1;
}

.text::before{
  color: #0ddbdb;
  animation: glitch-effect 2s infinite;
}

.text::after{
  color: #ed155d;
  animation: glitch-effect 1s infinite;
}

@keyframes glitch-effect {
  0%{
    left: -2px;
    top: -2px;
  }
  25%{
    left: 2px;
    top: 0px;
  }
  50%{
    left: -1px;
    top: 2px;
  }
  75%{
    left: 1px;
    top: -1px;
  }
  100%{
    left: 0px;
    top: -2px;
  }
}

  </style>
    <!-- <link rel="stylesheet" href="style.css"> -->
  </head>
  <body>
    <h3><font color="aqua"><i><b><marquee><font size="25">Welcome in the world of TERRAFORM</font></marquee><b><i></font></h3>
  <pre>
 <?php
   $cloudant_url=`head -n1 myinstanceip.txt`;
   $img_path="https://".$cloudant_url."/Shreyas.jpeg";
   echo "<br>";
   echo "<img src='${img_path}' width=290 height=330>";
?>
</pre>
   <h3><font color="aqua"><i>All thanks to Vimal Daga Sir<i></font></h3>
  <div class="text middle" data-text="Shreyas Basutkar">
    Shreyas Basutkar
  </div>
  </body>
</html>
