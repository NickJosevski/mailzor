using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;

using Autofac;
using Autofac.Core;

using NUnit.Framework;

namespace EmailModule.Specs.UnitTests
{
    [TestFixture]
    public class EmailSenderUnitTests
    {
        private IContainer _container;

        private ISmtpClient _mockSmtpClient;

        private const string TemplatesDirectory = @"..\..\..\Templates";

        [TestFixtureSetUp]
        public void FixtureSetup()
        {
        }

        [SetUp]
        public void Setup()
        {
            
        }

        private void ManualSetup(String templateOveride = null)
        {
            _mockSmtpClient = NSubstitute.Substitute.For<ISmtpClient>();

            var builder = new ContainerBuilder();

            builder.Register(c => new FileSystemEmailTemplateContentReader(templateOveride ?? TemplatesDirectory)).As<IEmailTemplateContentReader>();

            builder.RegisterType<EmailTemplateEngine>().As<IEmailTemplateEngine>();

            builder.Register(c => new EmailSender
            {
                CreateClientFactory = () => _mockSmtpClient
            }).As<IEmailSender>();

            builder.Register(
                c => new EmailSubsystem(
                        c.Resolve<IEmailTemplateEngine>(),
                        c.Resolve<IEmailSender>()))
                    .As<IEmailSystem>();

            _container = builder.Build();
        }

        [Test]
        public void ThrowsEmptyTemplateDirectoryException()
        {
            // Arrange
            ManualSetup("");
            
            // Act && Assert
            var inner = Assert.Throws<DependencyResolutionException>(() => _container.Resolve<IEmailSystem>()).InnerException;
            Assert.IsTrue(inner.Message.Contains("cannot be blank"));
            Assert.IsTrue(inner.Message.Contains("templateDirectory"));
        }

        [Test]
        public void MissingTemplateFile_NotFoundExpected()
        {
            ManualSetup();
            var subsystem = _container.Resolve<IEmailSystem>();
            // Arrange

            var email = new MyEmailStructure { To = "user@site.com", };

            // Act && Assert
            var msg = Assert.Throws<ArgumentException>( () =>subsystem.SendMail("MyEmailStructure", email)).Message;
            Assert.IsTrue(msg.Contains("check the name supplied matches the filename"), String.Format("Message actually was: {0}", msg));
            Assert.IsTrue(msg.Contains("MyEmailStructure"), String.Format("Message actually was: {0}", msg));
        }

        [Test]
        public void MissingFromFieldThrowsDetailedError()
        {
            ManualSetup();
            var subsystem = _container.Resolve<IEmailSystem>();
            // Arrange

            var email = new NewTaskEmailCommand { To = "user@site.com", };
            var templateName = email.GetType().Name;
            
            // Act && Assert
            var msg = Assert.Throws<ArgumentNullException>(() => subsystem.SendMail(templateName, email)).Message;
            Assert.IsTrue(msg.Contains("The supplied 'From' address cannot be null"), String.Format("Message actually was: {0}", msg));
        }

        // Has no tempalte
        public class MyEmailStructure
        {
            public String To { get; set; }
            public String From { get; set; }
            public String Subject { get; set; }
        }

        // Has a matching template
        public class NewTaskEmailCommand
        {
            public string From { get; set; }

            public string To { get; set; }

            public string Name { get; set; }

            public string VerificationUri { get; set; }
        }
    }
}
