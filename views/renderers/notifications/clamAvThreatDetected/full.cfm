<cfscript>
	stdOut = args.report.stdOut ?: "";
	stdErr = args.report.stdErr ?: "";
	env    = args.environment   ?: {};
</cfscript>

<cfoutput>
	<div class="alert alert-danger">
		<h3><i class="fa fa-fw fa-shield"></i> #translateResource( "clamav:notification.full.title" )#</h3>
		<hr>
		<p>#translateResource( "clamav:notification.full.warning" )#</p>
		<br>
		<pre>#stdOut##Chr( 10 )##stdErr#</pre>
	</div>

	<div class="well">
		<h4 class="green"> #translateResource( "clamav:notification.full.request.details.title" )#</h4>
		<dl class="dl-horizontal">
			<cfloop collection="#env#" item="key">
				<cfif IsSimpleValue( env[ key ] ?: "" ) && Len( Trim( env[ key ] ?: "" ) )>
					<dt>#key#</dt>
					<dd>#env[ key ]#</dd>
				</cfif>
			</cfloop>
		</dl>
	</div>
</cfoutput>