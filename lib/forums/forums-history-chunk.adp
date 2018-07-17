<p>
  #forums.Users_that_wrote_in_the_forum# <strong>@name@</strong>
</p>


<if @persons:rowcount;literal@ gt 0>
    <listtemplate name="persons"></listtemplate>
</if>
<else>
    <p>#forums.No_Postings#</p>
</else>
