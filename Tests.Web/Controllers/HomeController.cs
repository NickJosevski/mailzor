using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using EmailModule;

namespace Tests.Web.Controllers
{
    public class HomeController : Controller
    {
        private readonly IEmailSystem _mailzor;

        public HomeController(IEmailSystem mailzor)
        {
            _mailzor = mailzor;
        }

        public ActionResult Index()
        {
            ViewBag.Message = "Modify this template to jump-start your ASP.NET MVC application.";

            _mailzor.SendMail("TaskNotificationMessage",
                new TaskNotificationMessage
                {
                    To = "email@domain.com",
                    From = "source@domain.com"
                });

            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your app description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }

    public class TaskNotificationMessage
    {
        public string EmailAddress { get; set; }

        public DateTime Deadline { get; set; }

        public string From { get; set; }

        public string To { get; set; }

        public string Name { get; set; }

        public string VerificationUri { get; set; }

        public string LogOnUrl { get; set; }
    }
}
