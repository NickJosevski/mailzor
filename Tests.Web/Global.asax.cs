using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Autofac;
using EmailModule;

namespace Tests.Web
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            AuthConfig.RegisterAuth();
        }
    }

    public class MailzorModule : Autofac.Module
    {
        public string TemplatesDirectory { get; set; }
        public string SmtpServerIp { get; set; }
        public int SmtpServerPort { get; set; }

        protected override void Load(ContainerBuilder builder)
        {
            builder
                .Register(
                    c => new FileSystemEmailTemplateContentReader(TemplatesDirectory))
                .As<IEmailTemplateContentReader>();

            builder
                .RegisterType<EmailTemplateEngine>()
                .As<IEmailTemplateEngine>();

            builder
                .Register(
                    c => new EmailSender
                    {
                        CreateClientFactory = ()
                            => new SmtpClientWrapper(new SmtpClient(SmtpServerIp, SmtpServerPort))
                    })
                .As<IEmailSender>();

            builder
                .Register(
                    c => new EmailSubsystem(
                        c.Resolve<IEmailTemplateEngine>(),
                        c.Resolve<IEmailSender>()))
                .As<IEmailSystem>();
        }
    }
}