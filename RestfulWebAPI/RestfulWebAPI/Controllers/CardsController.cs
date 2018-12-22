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
    public class CardsController : ApiController
    {
        private APIDBEntities1 db = new APIDBEntities1();


        // GET: api/Validate
        //[ResponseType(typeof(CardValidationRule_Result))]
        //public IHttpActionResult GetValidate()
        //{
        //    ObjectResult<CardValidationRule_Result> result =db.CardValidationRule("234-234");
        //    return Ok(result);
        //}

        // GET: api/Cards
        /*public IQueryable<Card> GetCards()
        {
            return db.Cards;
        }*/
        [ResponseType(typeof(Card))]
        public IHttpActionResult GetCards()
        {
            ObjectResult<CardValidationRule_Result> result = db.CardValidationRule("234-234");
            return Ok(result);
        }

        // GET: api/Cards/5
        [ResponseType(typeof(Card))]
        public IHttpActionResult GetCard(int id)
        {
            Card card = db.Cards.Find(id);
            if (card == null)
            {
                return NotFound();
            }

            return Ok(card);
        }

        // PUT: api/Cards/5
        [ResponseType(typeof(void))]
        public IHttpActionResult PutCard(int id, Card card)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != card.ID)
            {
                return BadRequest();
            }

            db.Entry(card).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CardExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return StatusCode(HttpStatusCode.NoContent);
        }

        // POST: api/Cards
        [ResponseType(typeof(Card))]
        public IHttpActionResult PostCard(Card card)
        {
            ObjectResult<CardValidationRule_Result> result = db.CardValidationRule("234-234");
            return Ok(result);
        }

        // DELETE: api/Cards/5
        [ResponseType(typeof(Card))]
        public IHttpActionResult DeleteCard(int id)
        {
            Card card = db.Cards.Find(id);
            if (card == null)
            {
                return NotFound();
            }

            db.Cards.Remove(card);
            db.SaveChanges();

            return Ok(card);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool CardExists(int id)
        {
            return db.Cards.Count(e => e.ID == id) > 0;
        }
    }
}