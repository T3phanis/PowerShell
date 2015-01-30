schtasks.exe /change /tn "Scheduled Task Name" /Enable

function sendMail{

     $smtpServer = "your_mail.server.com"

     #Creating a Mail object
     $msg = new-object Net.Mail.MailMessage
	 
     #Creating SMTP server object
     $smtp = new-object Net.Mail.SmtpClient($smtpServer)

     #Email structure 
     $msg.From = "From@address.com"
     $msg.ReplyTo = "ReplyTo@address.com"
     $msg.To.Add("MessageTo@address.com")
	 $msg.subject = "Scheduled Task Enabled"
     $msg.body = " 
	 Add Message body between quotes!
	 "

     #Sending email 
     $smtp.Send($msg)
}

#Calling function
sendMail