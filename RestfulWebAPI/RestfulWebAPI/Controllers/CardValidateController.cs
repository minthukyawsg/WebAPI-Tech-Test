using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;
using RestfulWebAPI.Models;
using System.Data.Entity.Core.Objects;

namespace RestfulWebAPI.Controllers
{
    
    public class CardValidateController : ApiController
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private APIDBEntities1 db = new APIDBEntities1();
        // POST: api/Cards
        [ResponseType(typeof(CardValidationRule_Result))]
        public IHttpActionResult PostCardValidate(Payload payload)
        {
            ObjectResult<CardValidationRule_Result> result = db.CardValidationRule(payload.CardNumber);
            log.Info("Request Received.");
            return Ok(result);
        }

    }
}