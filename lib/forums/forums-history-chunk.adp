<p>
  #forums.Users_that_wrote_in_the_forum# <b>@name@</b>
</p>


<center>
<if @persons:rowcount@ gt 0>
<listtemplate name="persons"></listtemplate>
</if>
<else>
   #forums.No_Postings#
</else>
</center>
